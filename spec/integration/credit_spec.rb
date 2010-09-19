require 'spec_helper'

module Recurly
  describe Credit do
    describe "create a credit" do
      around(:each){|e| VCR.use_cassette('credit/create', &e)}

      let(:account){ Factory.create_account('credit-create') }

      before(:each) do
        credit = Factory.create_credit account.account_code,
                                        :amount => 9.50,
                                        :description => "free moniez"

        @credit = Credit.lookup(account.account_code, credit.id)
      end

      it "should save successfully" do
        @credit.created_at.should_not be_nil
      end

      it "should set the amount" do
        @credit.amount_in_cents.should == -950
      end

      it "should set the description" do
        @credit.description.should == "free moniez"
      end

    end

    describe "list credits for an account" do
      around(:each){|e| VCR.use_cassette('credit/list', &e)}
      let(:account){ Factory.create_account('credit-list') }

      before(:each) do
        Factory.create_credit(account.account_code, :amount => 1, :description => "one")
        Factory.create_credit(account.account_code, :amount => 2, :description => "two")
        Factory.create_credit(account.account_code, :amount => 3, :description => "three")
        @credits = Credit.list(account.account_code)
      end

      it "should return results" do
        @credits.length.should == 3
      end

      it "amounts should be correct" do
        @credits.map{|c| c.amount_in_cents}.should == [-300, -200, -100]
      end

      it "descriptions should be correct" do
        @credits.map{|c| c.description}.should == ["three", "two", "one"]
      end
    end

    describe "lookup a credit" do
      around(:each){|e| VCR.use_cassette('credit/lookup', &e)}
      let(:account) { Factory.create_account("credit-lookup") }

      before(:each) do
        @orig_credit = Factory.create_credit(account.account_code, :amount => 12.15)
        @credit = Credit.lookup(account.account_code, @orig_credit.id)
      end

      it "should return the correct credit" do
        @credit.should == @orig_credit
        @credit.amount_in_cents.should == -1215
      end
    end
  end
end