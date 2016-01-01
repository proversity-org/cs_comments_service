require 'spec_helper'

def create_comment_flag(comment_id, user_id)
  put "/api/v1/comments/#{comment_id}/abuse_flag", user_id: user_id
end

def create_thread_flag(thread_id, user_id)
  put "/api/v1/threads/#{thread_id}/abuse_flag", user_id: user_id
end

def remove_thread_flag(thread_id, user_id)
  put "/api/v1/threads/#{thread_id}/abuse_unflag", user_id: user_id
end

def remove_comment_flag(comment_id, user_id)
  put "/api/v1/comments/#{comment_id}/abuse_unflag", user_id: user_id
end

describe 'Abuse API' do
  before(:each) { set_api_key_header }
  let(:thread) { create_comment_thread_and_comments }
  let(:comment) { thread.comments.first }
  let(:user) { thread.author }

  describe 'flag a comment as abusive' do
    it 'create or update the abuse_flags on the comment' do
      prev_abuse_flaggers_count = comment.abuse_flaggers.length
      create_comment_flag(comment.id, user.id)

      comment.reload
      comment.abuse_flaggers.count.should == prev_abuse_flaggers_count + 1
      # verify that the thread doesn't automatically get flagged
      comment.comment_thread.abuse_flaggers.length.should == 0
    end

    it 'returns 400 when the comment does not exist' do
      create_comment_flag('does_not_exist', user.id)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:requested_object_not_found)
    end

    it 'returns 400 when user_id is not provided' do
      create_comment_flag(comment.id, nil)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:user_id_is_required)
    end
  end

  describe 'flag a thread as abusive' do
    it 'create or update the abuse_flags on the comment' do
      prev_abuse_flaggers_count = thread.abuse_flaggers.count
      create_thread_flag(thread.id, user.id)

      comment.reload
      comment.comment_thread.abuse_flaggers.count.should == prev_abuse_flaggers_count + 1
      # verify that the comment doesn't automatically get flagged
      comment.abuse_flaggers.length.should == 0
    end

    it 'returns 400 when the thread does not exist' do
      create_thread_flag('does_not_exist', user.id)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:requested_object_not_found)
    end

    it 'returns 400 when user_id is not provided' do
      create_thread_flag(thread.id, nil)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:user_id_is_required)
    end
  end

  describe 'unflag a comment as abusive' do
    it 'removes the user from the existing abuse_flaggers' do
      create_comment_flag(comment.id, user.id)

      comment.reload
      prev_abuse_flaggers = comment.abuse_flaggers
      prev_abuse_flaggers_count = prev_abuse_flaggers.count
      prev_abuse_flaggers.should include user.id

      remove_comment_flag(comment.id, user.id)

      comment.reload
      comment.abuse_flaggers.count.should == prev_abuse_flaggers_count - 1
      comment.abuse_flaggers.to_a.should_not include user.id
    end

    it 'returns 400 when the comment does not exist' do
      remove_comment_flag('does_not_exist', user.id)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:requested_object_not_found)
    end

    it 'returns 400 when the thread does not exist' do
      remove_thread_flag('does_not_exist', user.id)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:requested_object_not_found)
    end

    it 'returns 400 when user_id is not provided' do
      remove_thread_flag(thread.id, nil)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:user_id_is_required)
    end
  end

  describe 'unflag a thread as abusive' do
    it 'removes the user from the existing abuse_flaggers' do
      create_thread_flag(thread.id, user.id)

      thread.reload
      prev_abuse_flaggers = thread.abuse_flaggers
      prev_abuse_flaggers_count = prev_abuse_flaggers.count
      prev_abuse_flaggers.should include user.id

      remove_thread_flag(thread.id, user.id)

      thread.reload
      thread.abuse_flaggers.count.should == prev_abuse_flaggers_count - 1
      thread.abuse_flaggers.to_a.should_not include user.id
    end

    it 'returns 400 when the thread does not exist' do
      remove_thread_flag('does_not_exist', user.id)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:requested_object_not_found)
    end

    it 'returns 400 when user_id is not provided' do
      remove_thread_flag(thread.id, nil)
      last_response.status.should == 400
      parse(last_response.body).first.should == I18n.t(:user_id_is_required)
    end
  end
end
