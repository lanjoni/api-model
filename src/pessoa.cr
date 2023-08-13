require "pg"
require "json"

module Pessoa
  # Pode ser modificado para uma leitura de um arquivo .env
  DB = PG.connect("postgresql://root:root@localhost:5432/rinha_backend")

  def self.create_table
    DB.exec(
    "CREATE TABLE IF NOT EXISTS pessoa (
            id UUID NOT NULL,
            apelido VARCHAR(32) NOT NULL,
            nome VARCHAR(100) NOT NULL,
            nascimento VARCHAR(10) NOT NULL,
            stack VARCHAR(32),
            CONSTRAINT pk_pessoa PRIMARY KEY (id)
    );")
  end

  def self.create_pessoa(pessoa)
    custom_uuid = UUID.random

    DB.exec "INSERT INTO pessoa VALUES ($1, $2, $3, $4, $5)",
      custom_uuid, pessoa["apelido"], pessoa["nome"], pessoa["nascimento"], pessoa["stack"].to_s

    custom_uuid
  end

  def self.find_pessoa(id)
    if DB.scalar("SELECT COUNT(*) FROM pessoa WHERE id = '#{id}'") == 0
      return nil
    end

    id, apelido, nome, nascimento, stack = DB.query_one(
      "SELECT * FROM pessoa WHERE id = '#{id}' LIMIT 1",
      as: {UUID, String, String, String, String}
    ) # | return "Teste é problema"

    pessoa = {
      "id"         => id.to_s,
      "apelido"    => apelido,
      "nome"       => nome,
      "nascimento" => nascimento,
      "stack"      => stack,
    }.to_json

    return pessoa
  end

  def self.search_pessoas(termo)
    result = Array(String).new

    DB.query("SELECT * FROM pessoa WHERE nome ILIKE $1 OR apelido ILIKE $1 OR stack ILIKE $1", "%#{termo}%") do |rs|
      rs.each do
        result << {
          "id"         => rs.read(UUID).to_s,
          "apelido"    => rs.read(String),
          "nome"       => rs.read(String),
          "nascimento" => rs.read(String),
          "stack"      => rs.read(String),
        }.to_json
      end

      return result
    end
  end

  def self.count_pessoas
    DB.scalar("SELECT COUNT(*) FROM pessoa")
  end

  def self.verify_pessoa(nome)
    DB.scalar("SELECT COUNT(*) FROM pessoa WHERE nome = $1", nome)
  end

  def self.can_convert?(value : String) : Bool
    begin
      value.to_i
      return true
    rescue
      return false
    end
  end
end
