# OpenapiRailsTypedParameters

`openapi_rails_typed_parameters` is a library for performing parameter validation and coercion in Rails using OpenAPI definition files. It also supports providing static types through RBS generation.

This gem internally uses the [`openapi_first`](https://github.com/ahx/openapi_first) gem.

### Main Objectives

- Eliminate the code for params validation and type conversion (which is always a boring and routine task)
- Provide an RBS generator (so you don't have to memorize parameters)

### Differences from the `openapi_first` gem

- Offers more tightly coupled features to Rails
- Assists in statically typed programming by providing an RBS generator

## :warning: This gem is under development.

This gem is currently under development. It is not recommended for use in production applications. Backward compatibility is not guaranteed until version 1.0.0 is released.

Once all of the following TODOs are completed, we will release version 1.0.0.

### TODO

- [ ] Coercion to more Rails application appropriate types, such as `ActiveSupport::TimeWithZone`
- [ ] Provide more opinionated options for type conversions, such as coercion to `Symbol` for Enum value
- [ ] Include a RBS generation generator for statically typed programming
- [ ] Include RBS in the gem itself


## Installation

Add `openapi_rails_typed_parameters` to your Gemfile.

```rb
gem 'openapi_rails_typed_parameters'
```

Then, install rake task by generator.

```sh
bin/rails g openapi_rails_typed_parameters:install
```

## Usage

Run `openapi_rails_typed_parameters:generate` rake task.

```sh
bin/rails openapi_rails_typed_parameters:generate
```

If you update your OpenAPI definition, then generate again with `--force` option. It overwrites RBSs.

```sh
bin/rails openapi_rails_typed_parameters:generate --force
```

## Usage

Add `using OpenapiRailsTypedParameters` to your controller class. You can access statically typed parameters via `typed_params` method.

```rb
class UsersController < ApplicationController
  using OpenapiRailsTypedParameters

  def index
    # BEFORE: Default Rails code.
    params.permit(:role)
    role_string = params[:role]
    role =
      if role_string.present?
        if ['admin', 'maintainer', 'member'].include?(role_string)
          role_string.to_sym
        else
          raise 'Unknown `role` passed. available values are: [admin, maintainer, member].'
        end
      else
        :member # fallback to default
      end

    # AFTER: Typed parameters way.
    # role is validated, and it's type coerced.
    role = typed_params.query_params.role # :admin, :maintainer or :member

    @users = User.where(role:)
    render :index
  end
end

```

## RBS generation, static typing

Please add an initializer to your Rails application and specify the path to the OpenAPI schema file.

e.g.) `config/initializers/openapi.rb`

```openapi.rb
require 'openapi_rails_typed_parameters'

OpenapiRailsTypedParameters.configure do |config|
  config.schema_path = Rails.root.join('schema.yml')
end
```

If you want to customize generator behavior, edit `lib/tasks/openapi_rails_typed_parameters.rake`.

Then, you can use statically typed parameters. Please use `typed_params_for(:action_name)` instead of `typed_params`.

Enjoy statically typed params with your favorite LSP server.

```rb
class UsersController < ApplicationController
  using OpenapiRailsTypedParameters

  def index
    # BEFORE: RBS not injected.
    _ = typed_params

    # AFTER: RBS injected.
    _ = typed_params_for(:index)

    role = typed_params_for(:index).query_params.role
    @users = User.where(role:)
    render :index
  end
end
```

## Example

```schema.yml
openapi: 3.0.3
info:
  version: 1.0.0
  title: Sample App
servers:
  - url: https://example.com/
paths:
  /users:
    get:
      parameters:
        - name: role
          in: query
          required: true
          schema:
            type: string
            enum: [ admin, maintainer, member ]
            default: member
        - name: minimum
          in: query
          required: false
          schema:
            type: integer
        - name: maximum
          in: query
          required: false
          schema:
            type: integer
```

```users_controller.rb
class UsersController < ApplicationController
  using OpenapiRailsTypedParameters

  def index
    typed_params.validate!
    res = {
      role: typed_params.query_params.role # 'admin' or 'maintainer',
      minimum: typed_params.query_params.minimum # Integer value
      maximum: typed_params.query_params.maximum # Integer value
    }
    render json: res
  rescue OpenapiFirst::RequestInvalidError => e
    res = {
      # e.g.)
      # Query parameter is invalid: value at `/role` is not one of: ["admin", "maintainer"]
      message: e.message
    }
    render json: res, status: :bad_request
  end
end
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OpenapiRailsTypedParameters project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/supermomonga/openapi_rails_typed_parameters/blob/main/CODE_OF_CONDUCT.md).
