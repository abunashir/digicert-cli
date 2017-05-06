require "date"
require "digicert/cli/order_retriever"
require "digicert/cli/certificate_downloader"

module Digicert
  module CLI
    class OrderReissuer
      attr_reader :order_id, :options, :output_path

      def initialize(order_id:, **options)
        @order_id = order_id
        @options = options
        @output_path = options.fetch(:output, "/tmp")
      end

      def create
        apply_output_options(reissue_an_order)
      end

      def self.create(attributes)
        new(attributes).create
      end

      private

      def reissue_an_order
        Digicert::OrderReissuer.create(order_id: order_id)
      end

      def apply_output_options(reissue)
        if reissue
          print_request_details(reissue.requests.first)
          fetch_and_download_certificate(reissue.id)
        end
      end

      def print_request_details(request)
        request_id = request.id
        puts "Reissue request #{request_id} created for order - #{order_id}"
      end

      def fetch_and_download_certificate(reissued_order_id)
        if options[:output]
          order = fetch_reissued_order(reissued_order_id)
          download_certificate_order(order.certificate.id)
        end
      end

      def fetch_reissued_order(reissued_order_id)
        Digicert::CLI::OrderRetriever.fetch(
          reissued_order_id,
          wait_time: options[:wait_time],
          number_of_times: options[:number_of_times]
        )
      end

      def download_certificate_order(certificate_id)
        Digicert::CLI::CertificateDownloader.download(
          filename: order_id, path: output_path, certificate_id: certificate_id
        )
      end
    end
  end
end
