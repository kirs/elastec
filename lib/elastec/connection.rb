module Elastec
  module Connection
    def connection
      Elastec.connection
    end

    SERVER_ERROR = Elasticsearch::Transport::Transport::ServerError
  end
end