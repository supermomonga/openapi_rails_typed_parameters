# OpenapiRailsTypedParameters

`openapi_rails_typed_parameters` is a library for performing parameter validation and coercion in Rails using OpenAPI definition files. It also supports providing static types through RBS generation.

This gem internally uses the [`openapi_first`](https://github.com/ahx/openapi_first) gem.

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

## Usage

Please add an initializer to your Rails application and specify the path to the OpenAPI schema file.

e.g.) `config/initializers/openapi.rb`

```openapi.rb
require 'openapi_rails_typed_parameters'

OpenapiRailsTypedParameters.configure do |config|
  config.schema_path = Rails.root.join('schema.yml')
end
```

Then, add `using OpenapiRailsTypedParameters` to your controller class. You can access statically typed parameters via `typed_parameters` method.

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
            enum: [ admin, maintainer ]
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
    typed_params = typed_parameters
    typed_params.validate!
    res = {
      role: typed_params.query_params.role # 'admin' or 'maintainer',
      minimum: typed_params.query_params.minimum # Integer value
      maximum: typed_params.query_params.maximum # Integer value
    }
    render json: res.to_h
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
