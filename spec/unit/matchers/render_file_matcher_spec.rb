require 'spec_helper'

describe ChefSpec::Matchers::RenderFileMatcher do
  let(:path) { '/tmp/thing' }
  let(:file) { double('file', to: path, to_s: "file[#{path}]", performed_action?: true) }
  let(:chef_run) { double('chef run', find_resource: file) }
  subject { described_class.new(path) }

  describe '#failure_message_for_should' do
    it 'has the right value' do
      subject.matches?(chef_run)
      expect(subject.failure_message_for_should)
        .to eq(%Q(expected Chef run to render "#{path}"))
    end
  end

  describe '#failure_message_for_should_not' do
    it 'has the right value' do
      subject.matches?(chef_run)
      expect(subject.failure_message_for_should_not)
        .to eq(%Q(expected file "#{path}" to not be in Chef run))
    end
  end

  describe '#description' do
    it 'has the right value' do
      subject.matches?(chef_run)
      expect(subject.description).to eq(%Q(render file "#{path}"))
    end
  end

  context 'when the file is correct' do
    it 'matches' do
      expect(subject.matches?(chef_run)).to be_true
    end

    it 'adds the resource to the coverage report' do
      expect(ChefSpec::Coverage).to receive(:cover!).with(file)
      subject.matches?(chef_run)
    end
  end

  context 'when the file is not correct' do
    it 'does not match' do
      chef_run.stub(:find_resource).and_return(nil)
      failure = described_class.new('nope')
      expect(failure.matches?(chef_run)).to be_false
    end
  end
end
