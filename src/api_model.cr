require "kemal"

module ApiModel
  VERSION = "0.1.0"

  ## Connect to PostgreSQL database and retrieve data
  get "/players" do
    player = {name: "Guto", level: 100}
    player.to_json
  end

  post "/search/:id" do |context|
    id = context.params.url["id"]?
    ## Add: PostgreSQL verification
    name = context.params.body["name"]?
    level = context.params.body["level"]?

    if !id
      error = {message: "ID must be given"}.to_json
      halt context, status_code: 403, response: error
    end

    {id: id, name: name, level: level}
  end
end

Kemal.run
