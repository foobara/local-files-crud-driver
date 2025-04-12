RSpec.describe Foobara::LocalFilesCrudDriver do
  after do
    Foobara.reset_alls
  end

  let(:crud_driver) do
    described_class.new(data_path:, multi_process:)
  end
  let(:multi_process) { false }

  let(:data_path) { "#{__dir__}/../tmp/records.yml" }

  before do
    stub_class "Capybara", Foobara::Entity do
      attributes do
        id :integer
        name :string, :required
        age :integer, :required
        date_stuff do
          birthdays [:date]
          created_at :datetime
        end
      end

      primary_key :id
    end

    FileUtils.rm_f(data_path)
    Foobara::Persistence.default_crud_driver = crud_driver
  end

  it "can persist records" do
    fumiko = nil
    Capybara.transaction do
      fumiko = Capybara.create(name: "Fumiko", age: 100, date_stuff: { birthdays: [Date.today], created_at: Time.now })
      Capybara.create(name: "Barbara", age: 200, date_stuff: { birthdays: [Date.today], created_at: Time.now })
      Capybara.create(name: "Basil", age: 300, date_stuff: { birthdays: [Date.today], created_at: Time.now })
    end

    capybaras = Capybara.transaction do
      Capybara.all
    end

    expect(capybaras.map(&:name)).to match_array(%w[Fumiko Barbara Basil])

    Capybara.transaction do
      fumiko = Capybara.load(fumiko.id)
      expect(fumiko.age).to eq(100)
      fumiko.age += 1
    end

    Capybara.transaction do
      fumiko = Capybara.load(fumiko.id)
      expect(fumiko.age).to eq(101)
      expect(Capybara.count).to eq(3)
    end

    Capybara.transaction do
      fumiko = Capybara.load(fumiko.id)
      fumiko.hard_delete!
      expect(Capybara.count).to eq(2)
    end

    Capybara.transaction do
      expect(Capybara.count).to eq(2)
    end

    Capybara.transaction do |tx|
      tx.hard_delete_all!(Capybara)
      expect(Capybara.count).to eq(0)
    end

    Capybara.transaction do
      expect(Capybara.count).to eq(0)
    end
  end

  context "when using multiple processes requiring reading on each operation" do
    let(:multi_process) { true }

    it "can persist records" do
      fumiko = nil
      Capybara.transaction do
        fumiko = Capybara.create(name: "Fumiko", age: 100,
                                 date_stuff: { birthdays: [Date.today], created_at: Time.now })
        Capybara.create(name: "Barbara", age: 200, date_stuff: { birthdays: [Date.today], created_at: Time.now })
        Capybara.create(name: "Basil", age: 300, date_stuff: { birthdays: [Date.today], created_at: Time.now })
      end

      capybaras = Capybara.transaction do
        Capybara.all
      end

      expect(capybaras.map(&:name)).to match_array(%w[Fumiko Barbara Basil])

      Capybara.transaction do
        fumiko = Capybara.load(fumiko.id)
        expect(fumiko.age).to eq(100)
        fumiko.age += 1
      end

      Capybara.transaction do
        fumiko = Capybara.load(fumiko.id)
        expect(fumiko.age).to eq(101)
        expect(Capybara.count).to eq(3)
      end

      Capybara.transaction do
        fumiko = Capybara.load(fumiko.id)
        fumiko.hard_delete!
        expect(Capybara.count).to eq(2)
      end

      Capybara.transaction do
        expect(Capybara.count).to eq(2)
      end

      Capybara.transaction do |tx|
        tx.hard_delete_all!(Capybara)
        expect(Capybara.count).to eq(0)
      end

      Capybara.transaction do
        expect(Capybara.count).to eq(0)
      end
    end
  end
end
