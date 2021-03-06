require 'spec_helper'

describe SidekiqDupGuard::SidekiqUniqueJobFilter do

  context "call" do

    before :each do
      allow(Sidekiq.logger).to receive(:info).at_least(:once)
    end

    it "shouldn't enqueue sidekiq job if job already exists in queue when dup_guard_methods is all" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:get_sidekiq_job).and_return("e7ec009e89635e542e1da729")
      allow(SecureRandom).to receive(:hex).and_return([true, "e7ec009e89635e542e1da729"])
      expect{BarWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(BarWorker.jobs, :size).by(0)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqDupGuard: BarWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue with JID e7ec009e89635e542e1da729, skipping enqueue.")
    end

    it "shouldn't enqueue sidekiq job if job already exists in queue when dup_guard_methods is array of methods" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:get_sidekiq_job).and_return("e7ec009e89635e542e1da729")
      allow(SecureRandom).to receive(:hex).and_return([true, "e7ec009e89635e542e1da729"])
      expect{FooWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(FooWorker.jobs, :size).by(0)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqDupGuard: FooWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue with JID e7ec009e89635e542e1da729, skipping enqueue.").once
    end

    it "should enqueue sidekiq job if job doesn't exists in queue when dup_guard_methods is all" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:get_sidekiq_job).and_return(nil)
      expect(SecureRandom).to receive(:hex).and_return("e7ec009e89635e542e1da729")
      expect{BarWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(BarWorker.jobs, :size).by(1)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqDupGuard: BarWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue with JID e7ec009e89635e542e1da729, skipping enqueue.").at_most(0)
    end

    it "should enqueue sidekiq job if job doesn't exists in queue when dup_guard_methods is array of methods" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:get_sidekiq_job).and_return(nil)
      expect(SecureRandom).to receive(:hex).and_return("e7ec009e89635e542e1da729")
      expect{FooWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(FooWorker.jobs, :size).by(1)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqDupGuard: FooWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue with JID e7ec009e89635e542e1da729, skipping enqueue.").at_most(0)
    end
  end

  context "get_sidekiq_job" do
    it "should return sidekiq JID if sidekiq job is present" do
      Sidekiq::Queue.all.each(&:clear)
      Sidekiq::Testing.disable! do
        FooWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})
        jid = SidekiqDupGuard::SidekiqUniqueJobFilter.new.get_sidekiq_job("foo", "demo", {"args1" => "a", "args2" => "b"})
        expect(jid).not_to be_nil
      end
    end

    it "should return sidekiq JID if sidekiq job is present when args is empty" do
      Sidekiq::Queue.all.each(&:clear)
      Sidekiq::Testing.disable! do
        FooWorker.perform_async("demo", nil)
        jid = SidekiqDupGuard::SidekiqUniqueJobFilter.new.get_sidekiq_job("foo", "demo", nil)
        expect(jid).not_to be_nil
      end
    end

    it "should return nil if sidekiq job not present" do
      Sidekiq::Queue.all.each(&:clear)
      status, jid = SidekiqDupGuard::SidekiqUniqueJobFilter.new.get_sidekiq_job("foo", "demo", {"args1" => "a", "args2" => "b"})
      expect(jid).to be_nil
    end
  end
end
