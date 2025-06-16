require "foobara/spec_helpers/it_behaves_like_a_crud_driver"

RSpec.describe Foobara::LocalFilesCrudDriver do
  after { Foobara.reset_alls }

  let(:crud_driver) { described_class.new(data_path:, multi_process:) }
  let(:multi_process) { false }
  let(:data_path) { "#{__dir__}/../tmp/records.yml" }

  before do
    FileUtils.rm_f(data_path)
    Foobara::Persistence.default_crud_driver = crud_driver
  end

  it_behaves_like_a_crud_driver

  # rubocop:disable RSpec/EmptyExampleGroup
  context "when multi process" do
    let(:multi_process) { true }

    it_behaves_like_a_crud_driver
  end
  # rubocop:enable RSpec/EmptyExampleGroup
end
