require 'spec_helper'

describe SidekiqDupGuard::SidekiqUniqueJobFilter do

  context "call" do

    before :each do
      allow(Sidekiq.logger).to receive(:info).at_least(:once)
    end

    it "shouldn't enqueue sidekiq job if job already exists in queue when dup_guard_methods is all" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:sidekiq_job_present?).and_return([true, "e7ec009e89635e542e1da729"])
      allow(SecureRandom).to receive(:hex).and_return([true, "e7ec009e89635e542e1da729"])
      expect{BarWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(BarWorker.jobs, :size).by(0)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqUniqueJobFilter#call: BarWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue as JID-e7ec009e89635e542e1da729. Skipping enqueuing")
    end

    it "shouldn't enqueue sidekiq job if job already exists in queue when dup_guard_methods is array of methods" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:sidekiq_job_present?).and_return([true, "e7ec009e89635e542e1da729"])
      allow(SecureRandom).to receive(:hex).and_return([true, "e7ec009e89635e542e1da729"])
      expect{FooWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(FooWorker.jobs, :size).by(0)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqUniqueJobFilter#call: FooWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue as JID-e7ec009e89635e542e1da729. Skipping enqueuing").once
    end

    it "should enqueue sidekiq job if job doesn't exists in queue when dup_guard_methods is all" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:sidekiq_job_present?).and_return([false, nil])
      expect(SecureRandom).to receive(:hex).and_return("e7ec009e89635e542e1da729")
      expect{BarWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(BarWorker.jobs, :size).by(1)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqUniqueJobFilter#call: BarWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue as JID-e7ec009e89635e542e1da729. Skipping enqueuing").at_most(0)
    end

    it "should enqueue sidekiq job if job doesn't exists in queue when dup_guard_methods is array of methods" do
      allow_any_instance_of(SidekiqDupGuard::SidekiqUniqueJobFilter).to receive(:sidekiq_job_present?).and_return([false, nil])
      expect(SecureRandom).to receive(:hex).and_return("e7ec009e89635e542e1da729")
      expect{FooWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})}.to change(FooWorker.jobs, :size).by(1)
      expect(Sidekiq.logger).to have_received(:info).with("SidekiqUniqueJobFilter#call: FooWorker#demo '{\"args1\"=>\"a\", \"args2\"=>\"b\"}' job already exists in queue as JID-e7ec009e89635e542e1da729. Skipping enqueuing").at_most(0)
    end
  end

  context "sidekiq_job_present?" do
    it "should return true if sidekiq job is present" do
      Sidekiq::Queue.all.each(&:clear)
      Sidekiq::Testing.disable! do
        FooWorker.perform_async("demo", {"args1" => "a", "args2" => "b"})
        status, jid = SidekiqDupGuard::SidekiqUniqueJobFilter.new.sidekiq_job_present?("foo", "demo", {"args1" => "a", "args2" => "b"})
        expect(status).to eq(true)
        expect(jid).not_to be_nil
      end
    end

    it "should return false if sidekiq job not present" do
      Sidekiq::Queue.all.each(&:clear)
      status, jid = SidekiqDupGuard::SidekiqUniqueJobFilter.new.sidekiq_job_present?("foo", "demo", {"args1" => "a", "args2" => "b"})
      expect(status).to eq(false)
      expect(jid).to be_nil
    end
  end
end
