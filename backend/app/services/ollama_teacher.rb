# app/services/ollama_teacher.rb
require "net/http"
require "json"

class OllamaTeacher
  DEFAULT_MODEL = ENV.fetch("OLLAMA_MODEL", "phi3")
  DEFAULT_BASE_URL = ENV.fetch("OLLAMA_BASE_URL", "http://ollama:11434")
  GENERATE_PATH = "/api/generate"

  # Public: Generate a teacher-friendly summary for a student's PI/document.
  #
  # input_text: String with the whole document/PI in plain text.
  # student_name: optional string for context.
  #
  # Returns a plain text summary string.
  def self.summarize(input_text, student_name: nil)
    text = input_text.to_s.strip
    raise ArgumentError, "input_text is empty" if text.blank?

    chunks = chunk_text(text, max_words: 1200)

    if chunks.size == 1
      summarize_chunk(chunks.first, student_name: student_name)
    else
      partials = chunks.map.with_index do |chunk, i|
        summarize_chunk(chunk, student_name: student_name, chunk_index: i + 1, chunk_total: chunks.size)
      end
      combine_partials(partials, student_name: student_name)
    end
  end

  # Helper: Build input text from a PI record-like object (optional convenience).
  # Pass strings (nil-safe).
  def self.build_text_from_pi(description:, observations:, medrec:, activities:, interacttutorial:)
    [
      ["Description", description],
      ["Observations", observations],
      ["Medical/Health", medrec],
      ["Activities/Supports", activities],
      ["Tutor Interaction", interacttutorial],
    ].map do |title, content|
      c = content.to_s.strip
      next if c.blank?
      "#{title}:\n#{c}"
    end.compact.join("\n\n")
  end

  private

  def self.summarize_chunk(text_chunk, student_name: nil, chunk_index: nil, chunk_total: nil)
    who = student_name.present? ? "Student: #{student_name}\n" : ""
    chunk_note =
      if chunk_index && chunk_total
        "This is part #{chunk_index} of #{chunk_total}.\n"
      else
        ""
      end

    prompt = <<~PROMPT
You are an AI assistant helping a teacher understand a student's support plan/document.
Write a factual, concise summary based ONLY on the provided text. Do not invent details.

#{who}#{chunk_note}
Document text:
#{text_chunk}

STRICT OUTPUT RULES:
- Output plain text only.
- Do not use markdown.
- Do not use bullet symbols (•, -, *) and do not use numbering (1., 2., etc).
- Use exactly the headings below, in the exact order, each on its own line.
- If a section is not specified in the document, write: Not specified

REQUIRED OUTPUT FORMAT (exact headings):
Overview: <1-3 sentences>
Strengths: <1-2 sentences or Not specified>
Needs/Challenges: <1-3 sentences or Not specified>
Supports/Interventions: <1-3 sentences or Not specified>
Medical/Health: <1-2 sentences or Not specified>
Next steps for teacher: <1-3 sentences or Not specified>
    PROMPT

    call_ollama(prompt)
  end

  def self.combine_partials(partials, student_name: nil)
    who = student_name.present? ? "Student: #{student_name}\n" : ""

    prompt = <<~PROMPT
You are an AI assistant helping a teacher. Combine multiple partial summaries into ONE final summary.
Do not invent details. Prefer cautious wording. Remove duplicates.

#{who}
Partial summaries:
#{partials.join("\n\n---\n\n")}

STRICT OUTPUT RULES:
- Output plain text only.
- Do not use markdown.
- Do not use bullet symbols (•, -, *) and do not use numbering.
- Use exactly the headings below, in the exact order, each on its own line.
- If a section is not specified in the partials, write: Not specified

REQUIRED OUTPUT FORMAT (exact headings):
Overview: <1-3 sentences>
Strengths: <1-2 sentences or Not specified>
Needs/Challenges: <1-3 sentences or Not specified>
Supports/Interventions: <1-3 sentences or Not specified>
Medical/Health: <1-2 sentences or Not specified>
Next steps for teacher: <1-3 sentences or Not specified>
    PROMPT

    call_ollama(prompt)
  end

  def self.call_ollama(prompt)
    uri = URI.join(DEFAULT_BASE_URL, GENERATE_PATH)

    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 180

    req = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" })
    req.body = {
      model: DEFAULT_MODEL,
      prompt: prompt,
      stream: false,
      options: {
        temperature: 0.2,
        num_predict: 350,
        num_ctx: 1024
      }
    }.to_json

    res = http.request(req)

    unless res.is_a?(Net::HTTPSuccess)
      raise "Ollama API error: #{res.code} - #{res.body}"
    end

    raw = JSON.parse(res.body).fetch("response", "").to_s
    clean_plain_text(raw)
  end

  def self.clean_plain_text(text)
    # Some models still return code fences; strip them.
    text.to_s.gsub(/```.*?```/m, "").strip
  end

  # Simple sentence-based chunker.
  def self.chunk_text(text, max_words:)
    sentences = text.split(/(?<=[.!?])\s+/)
    chunks = []
    current = +""
    words = 0

    sentences.each do |s|
      wc = s.split.size
      if words + wc > max_words && current.present?
        chunks << current.strip
        current = +""
        words = 0
      end
      current << " " unless current.empty?
      current << s
      words += wc
    end

    chunks << current.strip if current.present?
    chunks
  end
end
