require "foobara/spec_helpers/it_behaves_like_a_crud_driver"

RSpec.describe Foobara::LocalFilesCrudDriver do
  after { Foobara.reset_alls }

  let(:crud_driver) { described_class.new(data_path:, multi_process:) }
  let(:multi_process) { false }
  let(:data_path) { "#{__dir__}/../tmp/test_data" }

  before do
    Dir["#{data_path}/*.yml"].each do |file|
      FileUtils.rm(file)
    end
    Foobara::Persistence.default_crud_driver = crud_driver
  end

  it_behaves_like_a_crud_driver

  # rubocop:disable-next RSpec/EmptyExampleGroup
  context "when multi process" do
    let(:multi_process) { true }

    it_behaves_like_a_crud_driver
  end
end
