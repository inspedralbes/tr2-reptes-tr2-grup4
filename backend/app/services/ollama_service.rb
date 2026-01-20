require "net/http"
require "json"

class OllamaService
  OLLAMA_URL = URI("http://ollama:11434/api/generate")

  def self.summarize(text, pi_data = {})
    Rails.logger.info "[OllamaService] Starting summarization, text length: #{text.length}, pi_data present: #{pi_data.present?}"

    # Chunk text if too large
    chunks = chunk_text(text)
    if chunks.size > 1
      Rails.logger.info "[OllamaService] Text chunked into #{chunks.size} parts"
      partial_results = chunks.map { |chunk| summarize_chunk(chunk, pi_data) }
      final_result = combine_results(partial_results, pi_data)
    else
      final_result = summarize_chunk(text, pi_data)
    end

    Rails.logger.info "[OllamaService] Summarization complete, result length: #{final_result.length}"
    final_result
  end

  private

  def self.chunk_text(text, max_words = 2000)
    # Split by sentences and group into chunks of max_words
    sentences = text.split(/(?<=[.!?])\s+/)
    chunks = []
    current_chunk = ""
    current_words = 0

    sentences.each do |sentence|
      word_count = sentence.split.size
      if current_words + word_count > max_words && !current_chunk.empty?
        chunks << current_chunk.strip
        current_chunk = sentence
        current_words = word_count
      else
        current_chunk += " " + sentence
        current_words += word_count
      end
    end
    chunks << current_chunk.strip if current_chunk.present?
    chunks
  end

  def self.summarize_chunk(text_chunk, pi_data)
    prompt = <<~PROMPT
You are an AI assistant. Strictly follow these instructions to process a student support plan PDF. Do not deviate, add extra text, use markdown, code blocks, lists, or any formatting. Output only raw JSON starting with { and ending with }.

Input:
- PDF Text: #{text_chunk}
- Existing Pi Data: #{pi_data.to_json}

Strict Rules:
- Do not use codeblocks and just output RAW JSON!!! starting with { and ending with }
- Do not summarize the PDF in extra text outside the pdf_summary field.
- Do not output existing Pi data in the JSON. Only output new or updated information extracted from the PDF after comparing to existing Pi.
- For each Pi field, extract only NEW relevant information from the PDF that is not already present in the existing Pi data. If the PDF has overlapping info, do not include it. Only include additions or updates that enhance the existing data.
- Append logic: If new info is relevant, provide the exact new text to append. Do not repeat existing content.
- If no new relevant info for a field, output an empty string "" for that field.
- IMPORTANT: Output each field value as a simple string, not an object or hash. Do not include keys like "existing", "pdf_added", "new" in the values. Just the plain new text to append.
- Fields details:
  - description: High-level plan overview or goals. Extract new goals or overviews from PDF not in existing.
  - observations: Behavioral or academic observations. Extract new observations not mentioned in existing.
  - medrec: Medical records, diagnoses, screenings. Extract new medical info not in existing (e.g., new diagnoses, test results).
  - activities: Interventions, activities, support strategies. Extract new activities or strategies not in existing.
  - interacttutorial: Interactions, check-ins, collaborative plans. Extract new interaction details or plans not in existing.
- pdf_summary: Provide a concise 2-3 sentence summary of the PDF's key content, focusing on new student-related information, assessments, or interventions that differ from existing Pi.
- Comparison: Carefully compare PDF content to existing Pi. Only include in JSON what is truly new or additive.

Output Format:
- Raw JSON only: {"description": "new text to append or empty", "observations": "new text", "medrec": "new text", "activities": "new text", "interacttutorial": "new text", "pdf_summary": "2-3 sentence summary"}
- No keys missing, no extra keys, no arrays, no nested objects, no markdown.

Example Output (showing only new additions):
{"description": "additional goal from PDF", "observations": "", "medrec": "new diagnosis found", "activities": "new intervention added", "interacttutorial": "", "pdf_summary": "The PDF introduces a new reading intervention not previously detailed."}
    PROMPT

    Rails.logger.info "[OllamaService] Generated prompt for chunk, length: #{prompt.length}"

    http = Net::HTTP.new(OLLAMA_URL.host, OLLAMA_URL.port)
    http.open_timeout = 10
    http.read_timeout = 900

    request = Net::HTTP::Post.new(OLLAMA_URL.path, { "Content-Type" => "application/json" })
    request.body = { model: "phi3", prompt: prompt, stream: false }.to_json

    Rails.logger.info "[OllamaService] Sending request to Ollama"
    response = http.request(request)

    if response.code != "200"
      Rails.logger.error "[OllamaService] Ollama error: #{response.body}"
      raise "Ollama API error: #{response.code} - #{response.body}"
    end

    raw_response = JSON.parse(response.body)["response"]
    Rails.logger.info "[OllamaService] Raw Ollama response: #{raw_response.inspect}"
    clean_response(raw_response)
  end

  def self.combine_results(results, pi_data)
    # Parse JSON results and merge by appending fields
    combined = pi_data.dup
    pdf_summaries = []

    results.each do |result|
      begin
        parsed = JSON.parse(result)
        combined["description"] = append_field(combined["description"], parsed["description"])
        combined["observations"] = append_field(combined["observations"], parsed["observations"])
        combined["medrec"] = append_field(combined["medrec"], parsed["medrec"])
        combined["activities"] = append_field(combined["activities"], parsed["activities"])
        combined["interacttutorial"] = append_field(combined["interacttutorial"], parsed["interacttutorial"])
        pdf_summaries << parsed["pdf_summary"] if parsed["pdf_summary"].present?
      rescue JSON::ParserError
        Rails.logger.warn "[OllamaService] Failed to parse result: #{result}"
      end
    end

    combined["pdf_summary"] = pdf_summaries.join(" ")
    combined.to_json
  end

  def self.append_field(existing, new)
    return existing unless new.present? && new != "$end"
    # If new is a hash (e.g., {"existing": "...", "pdf_added": "..."}), extract the addition
    if new.is_a?(Hash)
      addition = new["pdf_added"] || new["new"] || ""
      return existing if addition.blank?
      new = addition
    end
    [ existing, new ].compact.join(" ")
  end

  def self.clean_response(response)
    # Remove markdown code blocks
    cleaned = response.gsub(/```(?:json)?/, "").strip

    # Find the JSON substring between first { and last }
    start_index = cleaned.index("{")
    end_index = cleaned.rindex("}")

    if start_index && end_index && start_index < end_index
      json_str = cleaned[start_index..end_index]
      Rails.logger.info "[OllamaService] Cleaned response: #{json_str.inspect}"
      json_str
    else
      Rails.logger.warn "[OllamaService] No valid JSON found in response, using original"
      cleaned
    end
end
end
