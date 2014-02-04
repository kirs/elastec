require 'spec_helper'

describe Elastec::Indices do
  before(:each) do
    Elastec.indices_path = File.join(File.dirname(__FILE__), '..', 'fixtures')
    Elastec.connection = double("connection", indices: double("indicies"))
    %w(ONLY EXCEPT FORCE).each { |env| ENV.delete(env) }
  end

  let(:indices) { Elastec.connection.indices }

  it 'must correctly create indices' do
    allow(indices).to receive(:exists).and_return { false }
    expect(indices).to receive(:create).once.with(
      {:index=>"post_index", :body=>{"settings"=>1, "mappings"=>{"post"=>2}}}
    )
    expect(indices).to receive(:create).once.with(
      {:index=>"user_index", :body=>{"mappings"=>{"user"=>1}}}
    )

    subject.update
  end

  it 'must update indices' do
    allow(indices).to receive(:exists).and_return { true }
    expect(indices).to receive(:put_settings).once.with(
      {:index=>"post_index", :body=>1}
    )
    expect(indices).to receive(:put_mapping).once.with(
      {:index=>"post_index", :type=>"post", :body=>{"post"=>2}}
    )
    expect(indices).to receive(:put_mapping).once.with(
      {:index=>"user_index", :type=>"user", :body=>{"user"=>1}}
    )

    subject.update
  end

  it 'must delete specified indices' do
    ENV['ONLY'] = 'post_index'

    expect(indices).to receive(:delete).with({:index=>"post_index"}).once
    expect(indices).to_not receive(:delete).with({:index=>"user_index"})

    subject.delete
  end
end