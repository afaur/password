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
    column_title.setWidth(40)
    column_title.setDataCell(NSImageCell.alloc.init)
    @table_view.addTableColumn(column_title)

    column_username = NSTableColumn.alloc.initWithIdentifier("username")
    column_username.editable = false
    column_username.headerCell.setTitle("Name")
    column_username.setWidth(150)
    @table_view.addTableColumn(column_username)

=begin
    column_tweet = NSTableColumn.alloc.initWithIdentifier("tweet")
    column_tweet.editable = false
    column_tweet.headerCell.setTitle("Tweet")
    column_tweet.setWidth(290)
    @table_view.addTableColumn(column_tweet)
=end

    scroll_view.setDocumentView(@table_view)
  end

  def search(sender)

    Dispatch::Queue.concurrent.async do

      @search_result = [] #Password.all('master of disaster')

      Dispatch::Queue.main.sync { @table_view.reloadData }

    end

=begin
    text = @text_search.stringValue

    if text.length > 0

      query = text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      url = "https://api.twitter.com/1.1/search/tweets.json?q=#{query}"

      Dispatch::Queue.concurrent.async do

        @search_result = Password.all('master of disaster')

        Dispatch::Queue.main.sync { @table_view.reloadData }

      end

    end
=end

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
