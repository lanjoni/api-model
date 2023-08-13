require "kemal"
require "./pessoa"

module Main
  get "/" do |env|
    env.response.content_type = "application/json"
    env.response.status_code = 201

    {"message": "Olá Rinha de Backend, Crystal com Kemal chegou!"}.to_json
  end

  post "/pessoas" do |env|
    env.response.status_code = 201

    apelido = env.params.json["apelido"]?
    nome = env.params.json["nome"]?
    nascimento = env.params.json["nascimento"]?
    stack = env.params.json["stack"]?

    if !apelido || !nome || Pessoa.verify_pessoa(nome) != 0
      error = {"message": "Erro ao cadastrar pessoa"}.to_json
      halt env, status_code: 422, response: error
    end

    if nome.is_a?(Number)
      error = {"message": "Erro ao cadastrar pessoa"}.to_json
      halt env, status_code: 400, response: error
    end

    if stack.is_a?(Array)
      stack.map { |item|
        if Pessoa.can_convert?(item.to_s)
          error = {"message": "Erro ao cadastrar pessoa"}.to_json
          halt env, status_code: 400, response: error
        end
      }
    end

    custom_uuid = Pessoa.create_pessoa({
      "apelido"    => apelido,
      "nome"       => nome,
      "nascimento" => nascimento,
      "stack"      => stack,
    })

    env.response.headers["Location"] = "/pessoas/#{custom_uuid}"

    {"message": "Pessoa cadastrada com sucesso!"}
  end

  get "/pessoas/:id" do |env|
    id = env.params.url["id"]

    if !id.is_a?(UUID)
      error = {"message": "Erro ao procurar pessoa"}.to_json
      halt env, status_code: 404, response: error
    end

    pessoa = Pessoa.find_pessoa(id)

    if !pessoa
      error = {"message": "Erro ao procurar pessoa"}.to_json
      halt env, status_code: 404, response: error
    end

    pessoa
  end

  get "/pessoas" do |env|
    t = env.params.query["t"]?

    if !t || t.empty?
      error = {"message": "Erro ao procurar conteúdo"}.to_json
      halt env, status_code: 400, response: error
    end

    Pessoa.search_pessoas(t).to_json
  end

  get "/contagem-pessoas" do |env|
    env.response.status_code = 201
    Pessoa.count_pessoas.to_s
  end

  # Criação da tabela `pessoa` caso ainda não exista
  Pessoa.create_table

  Kemal.run
end
