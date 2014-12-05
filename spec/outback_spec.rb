require 'outback'
require 'spec_helper'

describe Outback do
  subject { described_class }
  let(:message) { double("message") }

  %i(verbose verbose? silent silent?).each do |method|
    it "responds to #{method}" do
      expect(subject.respond_to?(method)).to be_truthy
    end
  end

  describe "info" do
    { "to" => true, "to not" => false }.each do |message, boolean|
      context "if silent is #{boolean} will" do
        before do
          allow(described_class).to receive(:silent?).and_return(!boolean)
        end

        it "#{message} puts the message " do
          allow(subject).to receive(:puts).with(message).and_call_original
          expect(!!subject.info(message)).to eq(boolean)
          expect(subject).send(message.tr(" ", "_"), have_received(:puts).with(message))
        end
      end
    end
  end

  describe "debug" do
    { "to" => [[1,0]], "to not" => [[0,0], [0,1], [1,1]] }.each do |message, states|
      states.each do |booleans|
        context "if verbose is #{!booleans.first.zero?} and silent is #{!booleans.last.zero?}" do
          before do
            allow(described_class).to receive(:verbose?).and_return(!booleans.first.zero?)
            allow(described_class).to receive(:silent?).and_return(!booleans.last.zero?)
          end

          it "#{message} puts the message " do
            allow(subject).to receive(:puts).with(message).and_call_original
            expect(!!subject.debug(message)).to eq(!booleans.first.zero? && booleans.last.zero?)
            expect(subject).send(message.tr(" ", "_"), have_received(:puts).with(message))
          end
        end
      end
    end
  end

  describe "error" do
    { "to" => false, "to not" => true }.each do |message, boolean|
      context "if silent is #{boolean}" do
        before do
          allow(described_class).to receive(:silent?).and_return(boolean)
        end

        it "#{message} puts the message" do
          allow(subject).to receive(:puts).and_call_original
          expect(!!subject.error(message)).to eq(false)
          expect(subject).send(message.tr(" ", "_"), have_received(:puts))
        end
      end
    end
  end
end
