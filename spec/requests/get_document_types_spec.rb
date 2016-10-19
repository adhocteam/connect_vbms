require "spec_helper"

describe VBMS::Requests::GetDocumentTypes do
  describe "soap_doc" do
    subject { VBMS::Requests::GetDocumentTypes.new }

    it "generates valid SOAP" do
      xml = subject.soap_doc.to_xml
      xsd = Nokogiri::XML::Schema(fixture("soap.xsd"))
      expect(xsd.errors).to eq []
      errors = xsd.validate(parse_strict(xml))
      expect(errors).to eq []
    end
  end

  describe "handle_response" do
    before(:all) do
      request = VBMS::Requests::GetDocumentTypes.new
      xml = fixture("requests/get_document_types.xml")
      doc = parse_strict(xml)
      @response = request.handle_response(doc)
    end

    subject { @response }

    it "should return an array of DocumentType objects" do
      expect(subject).to be_an(Array)
      expect(subject).to all(be_a(VBMS::Responses::DocumentType))
      expect(subject.count).to eq(512)
    end

    it "should assign values properly to the DocumentType object" do
      dt = subject.first
      expect(dt.type_id).to eq("431")
      expect(dt.description).to eq("VA 21-4706c Court Appointed Fiduciarys Accounting")
    end
  end
end
