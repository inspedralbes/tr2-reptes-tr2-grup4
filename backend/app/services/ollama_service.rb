require "net/http"
require "json"

class OllamaService
  OLLAMA_URL = URI("http://ollama:11434/api/generate")

  def self.summarize(text)
    Rails.logger.info "[OllamaService] Starting summarization, text length: #{text.length}"

    prompt = <<~PROMPT
     Resume breument el següent document en català.
     Explica la idea principal i els punts més rellevants en 4 o 5 frases màxim.
     No copiïs text literal del document.

     TEXT:
      #{text}
    PROMPT

    Rails.logger.info "[OllamaService] Generated prompt, length: #{prompt.length}"

    http = Net::HTTP.new(OLLAMA_URL.host, OLLAMA_URL.port)

    # TIMEOUTS
    http.open_timeout = 10
    http.read_timeout = 300

    request = Net::HTTP::Post.new(
      OLLAMA_URL.path,
      { "Content-Type" => "application/json" }
    )

    request.body = {
      model: "phi3",
      prompt: prompt,
      stream: false
    }.to_json

    Rails.logger.info "[OllamaService] Sending request to Ollama at #{OLLAMA_URL}"
    response = http.request(request)

    Rails.logger.info "[OllamaService] Received response, status: #{response.code}"

    if response.code != "200"
      Rails.logger.error "[OllamaService] Ollama error response: #{response.body}"
      raise "Ollama API error: #{response.code} - #{response.body}"
    end

    result = JSON.parse(response.body)["response"]
    Rails.logger.info "[OllamaService] Summarization complete, result length: #{result.length}"
    result
  end
end
