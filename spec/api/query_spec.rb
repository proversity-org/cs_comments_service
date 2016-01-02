require 'spec_helper'
require 'faker'

describe 'app' do

  before(:each) { set_api_key_header }
  let(:body) { Faker::Lorem.word }

  describe 'thread search' do
    describe 'GET /api/v1/search/threads' do
      it 'returns thread with query match' do
        thread = create(:comment_thread, body: body)
        refresh_es_index

        get '/api/v1/search/threads', text: body
        last_response.should be_ok
        result = parse(last_response.body)['collection'].select { |t| t['id'] == thread.id.to_s }.first
        check_thread_result_json(nil, thread, result)
      end

    end
  end

  describe 'comment search' do
    describe 'GET /api/v1/search/threads' do
      it 'returns thread with comment query match' do
        comment = create(:comment, body: body)
        thread = comment.comment_thread
        refresh_es_index

        get '/api/v1/search/threads', text: body
        last_response.should be_ok
        result = parse(last_response.body)['collection'].select { |t| t['id'] == thread.id.to_s }.first
        check_thread_result_json(nil, thread, result)
      end
    end
  end
end
