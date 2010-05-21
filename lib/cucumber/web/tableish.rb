require 'nokogiri'

module Cucumber
  module Web
    module Tableish
      # This method returns an Array of Array of String, using CSS3 selectors.
      # This is particularly handy when using Cucumber's Table#diff! method.
      #
      # The +row_selector+ argument must be a String, and picks out all the rows
      # from the web page's DOM. If the number of cells in each row differs, it
      # will be constrained by (or padded with) the number of cells in the first row
      #
      # The +column_selectors+ argument must be a String or a Proc, picking out
      # cells from each row. If you pass a Proc, it will be yielded an instance
      # of Nokogiri::HTML::Element.
      #
      # == Example with a table
      #
      #   <table id="tools">
      #     <tr>
      #       <th>tool</th>
      #       <th>dude</th>
      #     </tr>
      #     <tr>
      #       <td>webrat</td>
      #       <td>bryan</td>
      #     </tr>
      #     <tr>
      #       <td>cucumber</td>
      #       <td>aslak</td>
      #     </tr>
      #   </table>
      #
      #   t = tableish('table#tools tr', 'td,th')
      #
      # == Example with a dl
      #
      #   <dl id="tools">
      #     <dt>webrat</dt>
      #     <dd>bryan</dd>
      #     <dt>cucumber</dt>
      #     <dd>aslak</dd>
      #   </dl>
      #
      #   t = tableish('dl#tools dt', lambda{|dt| [dt, dt.next.next]})
      #
      def tableish(row_selector, column_selectors)
        html = defined?(Capybara) ? body : response_body
        _tableish(html, row_selector, column_selectors)
      end

      def _row_width(row, column_selectors)
        cells = _select_cells(column_selectors, row)

        cells.inject(0) do |result, cell|
          colspan = cell['colspan'].nil? ? 1 : cell['colspan'].to_i
          result + colspan
        end
      end

      def _column_height(rows)
        rows.size
      end

      def _select_cells(column_selectors, row)
        case (column_selectors)
          when String
            row.search(column_selectors)
          when Proc
            column_selectors.call(row)
        end
      end

      def _pad_grid_with_blanks(grid)
        grid.each do |grid_row|
          grid_row.size.times do |i|
            grid_row[i] = "" if grid_row[i] == nil
          end
        end
      end

      def _cell_value(cell)
        case cell
          when String then
            cell.strip
          when nil then
            ''
          else
            cell.text.strip
        end
      end

      # Comments:
      # First row defines width

      def _tableish(html, row_selector, column_selectors) #:nodoc
        doc = Nokogiri::HTML(html)
        # Parse the table.
        rows = doc.search(row_selector)

        max_columns = _row_width(rows[0], column_selectors)
        max_rows = _column_height(rows)

        # Initialize a 2 dimensional array representing the size of the table in tableish format
        grid = Array.new(max_rows) { Array.new(max_columns, nil) }

        table_row_index = 0
        grid.each_with_index do |grid_row, grid_row_index|
          row = rows[table_row_index]

          cells = _select_cells(column_selectors, row)
          table_column_index = 0
          grid_row.size.times do |grid_column_index|
            next if grid[grid_row_index][grid_column_index] != nil

            cell = cells[table_column_index]
            if cell
              col_span, row_span = 1, 1
              row_span = cell['rowspan'].to_i - 1 if cell['rowspan']
              col_span = cell['colspan'].to_i - 1 if cell['colspan']

              # draw blank cells based on colspan and rowspan
              if cell['rowspan'] && cell['colspan']
                row_span.times do |row_offset|
                  row_offset_index = grid_row_index + (row_offset + 1)
                  col_span.times do |col_offset|
                    col_offset_index = grid_column_index + (col_offset + 1)
                    grid[row_offset_index][col_offset_index] = "" unless row_offset_index >= rows.size || col_offset_index >= max_columns
                  end
                end
              end

              if cell['rowspan']
                row_span.times do |row_span_offset|
                  row_offset_index = grid_row_index + (row_span_offset + 1)
                  grid[row_offset_index][grid_column_index] = "" unless row_offset_index >= rows.size
                end
              end

              if cell['colspan']
                col_span.times do |col_span_offset|
                  col_offset_index = grid_column_index + (col_span_offset + 1)
                  grid[grid_row_index][col_offset_index] = "" unless col_offset_index >= max_columns
                end
              end

              # print cell value into grid and move to next table column, only if cell hasn't been touched yet
              if grid[grid_row_index][grid_column_index] == nil
                table_column_index += 1
                grid[grid_row_index][grid_column_index] = _cell_value(cell)
              end
            end
          end
          table_row_index += 1
        end

        _pad_grid_with_blanks(grid)

        grid
      end

      def _parse_spans(cell)
        cell.is_a?(Nokogiri::XML::Node) ?
          [cell.attributes['rowspan'].to_s.to_i || 1, cell.attributes['colspan'].to_s.to_i || 1] :
          [1, 1]
      end
    end
  end
end

World(Cucumber::Web::Tableish)
