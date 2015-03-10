
require 'pork/test'

describe Pork::Inspect do
  would 'hash' do
    Pork::Inspect.with_auto(
      {:b => 1, :a => 0}, :==, [{:a => 1, :b => 0}], false).
      should.eq '{:a=>0, :b=>1}.==({:a=>1, :b=>0}) to return true'
  end

  would 'newline' do
    obj, arg = 'a'*80, 'b'*80
    Pork::Inspect.with_auto(obj, :==, [arg], true).
      should.eq "\n#{obj.inspect}.==(\n#{arg.inspect}) to return false"
  end

  would 'diff' do
    s = File.read(__FILE__)
    n = s.count("\n")
    Pork::Inspect.with_auto(s, :==, ["#{s}b\n"], true).
      should.eq "String#==(\n#{n}a#{n+1}\n> b\n) to return false"
  end

  would '#diff_hash with nil and <undefined>' do
    z = 'z'*80
    a, b = {:z => z, :a => nil}, {:z => z}
    Pork::Inspect.with_auto(a, :==, [b], false).should.start_with? <<-MSG.chop

\tHash with key path: :a
nil.==(<undefined>) to return true
    MSG

    Pork::Inspect.with_auto(b, :==, [a], false).should.start_with? <<-MSG.chop

\tHash with key path: :a
<undefined>.==(nil) to return true
    MSG
  end

  would '#diff_hash with nil and <out-of-bound>' do
    z = 'z'*80
    a, b = {:a => {:b => [z, nil]}}, {:a => {:b => [z]}}
    Pork::Inspect.with_auto(a, :==, [b], false).should.start_with? <<-MSG.chop

\tHash with key path: :a/:b/1
nil.==(<out-of-bound>) to return true
    MSG

    Pork::Inspect.with_auto(b, :==, [a], false).should.start_with? <<-MSG.chop

\tHash with key path: :a/:b/1
<out-of-bound>.==(nil) to return true
    MSG
  end

  would '#diff_hash with string keys and symbol keys' do
    z = 'z'*80
    a, b = {:a => z}, {'a' => z}
    Pork::Inspect.with_auto(a, :==, [b], false).should.start_with? <<-MSG.chop

\tHash with key path: :a
#{z.inspect}.==(\n<undefined>) to return true

\tHash with key path: "a"
<undefined>.==(#{z.inspect}) to return true
    MSG
  end

  would '#diff_hash' do
    a = {"category_chats"=>[{"category_name"=>"Cat", "experts_url"=>"cat-experts", "chat_list"=>[{"mentee"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "mentor"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"menmen", "name"=>"Menmen", "level"=>"mentor", "rating"=>0.0, "role"=>"mentor", "avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}]}], "longterm"=>[{"rate"=>"3.00", "credit"=>"7.00", "valid_from"=>1416148781, "valid_to"=>1416235181, "mentee"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "mentor"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"menmen", "name"=>"Menmen", "level"=>"mentor", "rating"=>0.0, "role"=>"mentor", "avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}], "my"=>[], "recent_chats"=>[{"request"=>{}, "type"=>"message", "id"=>"e71bca4b-a617-4edc-9816-7fc3034c64ea", "content"=>"hi", "created_at"=>"2014-11-16T14:39:41Z", "read_at"=>nil, "sender"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "receiver"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"menmen", "name"=>"Menmen", "level"=>"mentor", "rating"=>0.0, "role"=>"mentor", "avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}]}

    b = {"category_chats"=>[{"category_name"=>"Cat", "experts_url"=>"cat-experts", "chat_list"=>[{"mentee"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}]}], "longterm"=>[{"rate"=>"3.00", "credit"=>"7.00", "valid_from"=>1416148781, "valid_to"=>1416235181, "mentee"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "mentor"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"menmen", "name"=>"Menmen", "level"=>"mentor", "rating"=>0.0, "role"=>"mentor", "avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}], "my"=>[{"mentee"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}], "recent_chats"=>[{"request"=>{}, "type"=>"message", "id"=>"e71bca4b-a617-4edc-9816-7fc3034c64ea", "content"=>"hi", "created_at"=>"2014-11-16T14:39:41Z", "read_at"=>nil, "sender"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "receiver"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"menmen", "name"=>"Menmen", "level"=>"mentor", "rating"=>0.0, "role"=>"mentor", "avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}]}

    f = expect.raise(Pork::Failure){ expect(a, 'Additional Message').eq(b) }
    expect(f.message).eq <<-MSG.sub(/\AExpect/, 'Expect ').chop
Expect
\tHash with key path: "category_chats"/0/"chat_list"/0/"mentor"
{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"menmen", "name"=>"Menmen", "level"=>"mentor", "rating"=>0.0, "role"=>"mentor", "avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/556611444ab1143c8ad30206fda3926f?d=mm?s=64&d=mm"}.==(
<undefined>) to return true

\tHash with key path: "my"/0
<out-of-bound>.==({"mentee"=>{"timezone_str"=>"+00:00", "timezone_offset"=>0, "timezone_display"=>"UTC (+00:00)", "username"=>"example", "name"=>"Example", "level"=>"mentor", "rating"=>0.0, "role"=>"user", "avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm", "small_avatar_url"=>"https://www.gravatar.com/avatar/55502f40dc8b7c769880b10874abc9d0?d=mm?s=64&d=mm"}, "chatroom_id"=>"8c3dd9387dd30499a4053e07e4a41be4", "chatroom_firebase_id"=>"49c31f7444e199bdaea610dbe518d329"}) to return true
Additional Message
    MSG
  end
end
