require 'open3'

module VBMS
  FILEDIR = File.dirname(File.absolute_path(__FILE__))
  DO_WSSE = File.join(FILEDIR, '../../src/do_wsse.sh')

  XML_NAMESPACES = {
    "v4" => "http://vbms.vba.va.gov/external/eDocumentService/v4",
    "ns2" => "http://vbms.vba.va.gov/cdm/document/v4",
  }

  class ClientError < StandardError
  end

  class HTTPError < ClientError
    attr_reader :code, :body

    def initialize(code, body)
      super(code)
      @code = code
      @body = body
    end
  end

  class SOAPError < ClientError
  end

  class ExecutionError < ClientError
    attr_reader :cmd, :output

    def initialize(cmd, output)
      super("Error running cmd: #{cmd}\nOutput: #{output}")
      @cmd = cmd
      @output = output
    end
  end

  DocumentType = Struct.new("DocumentType", :type_id, :description)
  Document = Struct.new("Document", :document_id, :filename, :doc_type, :source, :received_at)
  DocumentWithContent = Struct.new("DocumentWithContent", :document, :content)

  private
    def self.load_erb(path)
      location = File.join(FILEDIR, "../templates", path)
      return ERB.new(File.read(location))
    end

    def self.decrypt_message(infile, keyfile, keypass, logfile, ignore_timestamp = false)
      output, errors, status = Open3.capture3(DO_WSSE, '-i', infile, '-k', keyfile, '-p', keypass, '-l', logfile, ignore_timestamp ? '-t' : '')
      if status != 0
        raise ExecutionError.new(DO_WSSE + " DecryptMessage", errors)
      end
      return output
    end

    def self.encrypted_soap_document(infile, keyfile, keypass, request_name)
      output, errors, status = Open3.capture3(DO_WSSE, '-e', '-i', infile, '-k', keyfile, '-p', keypass, '-n', request_name)
      if status != 0
        raise ExecutionError.new(DO_WSSE + " EncryptSOAPDocument", errors)
      end
      return output
    end
end
