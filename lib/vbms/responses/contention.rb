# frozen_string_literal: true

require 'ostruct'

module VBMS
  module Responses
    class Contention < OpenStruct
      def self.create_from_xml(xml, key: :list_of_contentions)
        data = XMLHelper.convert_to_hash(xml.to_xml)[key]

        new(
          id: data[:@id],
          text: Nokogiri::HTML.fragment(data[:@title]).text,
          start_date: data[:start_date],
          submit_date: data[:submit_date],
          actionable_item: data[:@actionable_item],
          awaiting_response: data[:@awaiting_response],
          claim_id: data[:@claim_id],
          classification_cd: data[:@classification_cd],
          contention_category: data[:@contention_category],
          file_number: data[:@file_number],
          level_status_code: data[:@level_status_code],
          medical: data[:@medical],
          participant_contention: data[:@partcipant_contention],
          secondary_to_contention_id: data[:@secondary_to_contention_id],
          type_code: data[:@type_code],
          working_contention: data[:@working_contention],
          title: data[:@title],
          disposition: data[:@disposition],
          special_issues: create_issues(data[:issue])
        )
      end

      def self.create_issues(*issues)
        issues.compact.flatten.map { |issue| VBMS::Responses::Issue.create(issue) }
      end
    end
  end
end
