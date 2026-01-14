require 'net/http'
require 'json'

class OllamaService
  OLLAMA_URL = URI('http://ollama:11434/api/generate')

  def self.summarize(text)
    prompt = <<~PROMPT 
     Resume breument el següent document en català.
     Explica la idea principal i els punts més rellevants en 4 o 5 frases màxim.
     No copiïs text literal del document.

     TEXT:
      #{text}
    PROMPT

    http = Net::HTTP.new(OLLAMA_URL.host, OLLAMA_URL.port)

    # TIMEOUTS
    http.open_timeout = 10 
    http.read_timeout = 300

    request = Net::HTTP::Post.new(
      OLLAMA_URL.path,
      { 'Content-Type' => 'application/json' }
    )

    request.body = {
      model: 'llama3',
      prompt: prompt,
      stream: false,
    }.to_json
    response = http.request(request)
    JSON.parse(response.body)['response']
  end
end