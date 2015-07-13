class Pass
  attr_accessor :title, :user
  def initialize(title, user)
    @title = title
    @user = user
  end

  def match?(word)
    title.match(word) || user.match(word)
  end
end

class Pboard
  def self.copy(data)
    pboard = NSPasteboard.generalPasteboard
    pboard.declareTypes([NSStringPboardType], owner:nil);
    pboard.setString(data, forType:NSStringPboardType)
  end

  # broken
  def self.paste
    pboard = NSPasteboard.generalPasteboard
    pboard.declareTypes([NSStringPboardType], owner:nil);
    pboard.stringForType(NSStringPboardType)
  end

  def self.clear!
    pboard = NSPasteboard.generalPasteboard
    pboard.declareTypes([NSStringPboardType], owner:nil);
    pboard.clearContents
  end
end

class MainController < TeacupWindowController
  stylesheet :main_stylesheet

  def teacup_layout
    @text_search = subview(NSTextField, :text_search,
      stringValue: 'xcode crash'
      )

    subview(NSButton, :search_button,
      action: 'search:',
      target: self,
      )

    scroll_view = subview(NSScrollView, :scroll_view)

    @table_view = subview(NSTableView, :table_view,
      delegate: self,
      dataSource: self,
      )

    column_title = NSTableColumn.alloc.initWithIdentifier("title")
    column_title.editable = false
    column_title.headerCell.setTitle("Title")
    column_title.setWidth(150)
    @table_view.addTableColumn(column_title)

    column_username = NSTableColumn.alloc.initWithIdentifier("username")
    column_username.editable = false
    column_username.headerCell.setTitle("Name")
    column_username.setWidth(150)
    @table_view.addTableColumn(column_username)

    scroll_view.setDocumentView(@table_view)

    @original_result = [
      Pass.new('GMail', 'afaur@gmail.com'),
      Pass.new('BitBucket', 'afaur'),
      Pass.new('Github', 'afaur'),
    ]
    @search_result = @original_result
    reload_table
  end

  def reload_table
    Dispatch::Queue.concurrent.async do
      Dispatch::Queue.main.sync do
        @table_view.reloadData
      end
    end
  end

  def search(sender)
    text = @text_search.stringValue
    @search_result = @original_result.select do |result|
      result.match?(text) or text == ''
    end
    reload_table
  end

  def numberOfRowsInTableView(aTableView)
    return 0 if @search_result.nil?
    return @search_result.size
  end

  def tableView(aTableView,
                objectValueForTableColumn: aTableColumn,
                row: rowIndex)
    case aTableColumn.identifier
    when "title"
      return @search_result[rowIndex].title
    when "username"
      return @search_result[rowIndex].user
    #when "actions"
      #return @search_result[rowIndex].
    end
  end

end
