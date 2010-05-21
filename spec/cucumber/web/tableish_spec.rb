# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

def World(* a)
  ;
end

require 'cucumber/web/tableish'

module Cucumber
  module Web
    describe Tableish do
      include Tableish

      unless RUBY_PLATFORM =~ /java/
        it "should convert a table" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <th>tool</th>
                <th>dude</th>
              </tr>
              <tr>
                <td>webrat</td>
                <td>bryan</td>
              </tr>
              <tr>
                <td>cucumber</td>
                <td>aslak</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            %w{ tool dude },
            %w{ webrat bryan },
            %w{ cucumber aslak }
          ]
        end

        it "should size to the first row" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <th>tool</th>
                <th>dude</th>
              </tr>
              <tr>
                <td>webrat</td>
                <td>bryan</td>
                <td>crapola</td>
              </tr>
              <tr>
                <td>cucumber</td>
                <td>aslak</td>
                <td>gunk</td>
                <td>filth</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            ['tool', 'dude',],
            ['webrat', 'bryan'],
            ['cucumber', 'aslak']
          ]
        end

        it "should pad with empty Strings if some rows are shorter" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <th>tool</th>
                <th>dude</th>
              </tr>
              <tr>
                <td>webrat</td>
                <td>bryan</td>
              </tr>
              <tr>
                <td>cucumber</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            %w{ tool dude },
            %w{ webrat bryan },
            ['cucumber', '']
          ]
        end

        it "should handle a single row" do
          html = <<-HTML
            <table>
              <tr>
                <td>a</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a']
          ]
        end

        it "should handle two rows" do
          html = <<-HTML
            <table>
              <tr>
                <td>a</td>
              </tr>
              <tr>
                <td>b</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a'],
            ['b']
          ]
        end

        it "should handle one row with two columns" do
          html = <<-HTML
            <table>
              <tr>
                <td>a</td>
                <td>b</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a', 'b']
          ]
        end

        it "should handle a single colspan" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <td colspan="3">x</td>
              </tr>
              <tr>
                <td>a</td>
                <td>b</td>
                <td>c</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            ['x', '', ''],
            ['a', 'b', 'c']
          ]
        end

        it "should handle a single rowspan" do
          html = <<-HTML
            <table>
              <tr>
                <th rowspan='2'>a</th>
                <th>b</th>
              </tr>
              <tr>
                <th>c</th>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a', 'b'],
            ['', 'c']
          ]
        end

        it "should handle colspan and rowspan" do
          html = <<-HTML
            <table>
              <tr>
                <th colspan="3">a</th>
                <th rowspan="2">b</th>
                <th>c</th>
                <th>d</th>
              </tr>
              <tr>
                <td>e</td>
                <td>f</td>
                <td>g</td>
                <td>h</td>
                <td>i</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a', '', '', 'b', 'c', 'd'],
            ['e', 'f', 'g', '', 'h', 'i']
          ]
        end

        it "should handle a cell with a colspan and a rowspan" do
          html = <<-HTML
            <table>
              <tr>
                <td rowspan="2" colspan="2">a</td>
                <td>b</td>
              </tr>
              <tr>
                <td>c</td>
              </tr>
              <tr>
                <td>d</td>
                <td>e</td>
                <td>f</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a', '', 'b'],
            ['', '', 'c'],
            ['d', 'e', 'f']
          ]
        end

        it "should handle a single colspan on a single row" do
          html = <<-HTML
            <table>
              <tr>
                <td colspan="3">x</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['x', '', '']
          ]
        end

        it "should handle a colspan on the second row" do
          html = <<-HTML
            <table>
              <tr>
                <td rowspan="2">w</td>
                <td>x</td>
                <td>y</td>
              </tr>
              <tr>
                <td colspan="2">a</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['w', 'x', 'y'],
            ['', 'a', '']
          ]
        end

        it "should handle a colspan with two cells on a single row" do
          html = <<-HTML
            <table>
              <tr>
                <td colspan="2">a</td>
                <td>b</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a', '', 'b']
          ]
        end

        it "should handle a rowspan with two cells on a single column" do
          html = <<-HTML
            <table>
              <tr>
                <td rowspan="2">a</td>
              </tr>
              <tr>
                <td>b</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a'],
            ['']
          ]
        end

        it "should handle a single rowspan with multiple rows" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <td rowspan="2">x</td>
                <td>y</td>
              </tr>
              <tr>
                <td>a</td>
              </tr>
              <tr>
                <td>d</td>
                <td>e</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            ['x', 'y'],
            ['', 'a'],
            ['d', 'e']
          ]
        end

        it "should handle a cell with a 3x3 colspan and a rowspan" do
          html = <<-HTML
            <table border="1">
              <tr>
                <td rowspan="3" colspan="3">a</td>
                <td>d</td>
              </tr>
              <tr>
                <td>d</td>
              </tr>
              <tr>
                <td>d</td>
              </tr>
              <tr>
                <td>d</td>
                <td>d</td>
                <td>d</td>
                <td>d</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table tr', 'td,th').should == [
            ['a', '', '', 'd'],
            ['', '', '', 'd'],
            ['', '', '', 'd'],
            ['d', 'd', 'd', 'd']
          ]
        end

        it "should handle colspan and rowspan on multiple rows and columns" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <td rowspan="4">a</td>
                <td>b</td>
                <td>c</td>
                <td>d</td>
              </tr>
              <tr>
                <td colspan="3">e</td>
              </tr>
              <tr>
                <td rowspan="2" colspan="2">f</td>
                <td>g</td>
              </tr>
              <tr>
                <td>h</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            ['a', 'b', 'c', 'd'],
            ['', 'e', '', ''],
            ['', 'f', '', 'g'],
            ['', '', '', 'h'],
          ]
        end

        it "should convert a dl" do
          html = <<-HTML
            <dl id="tools">
              <dt>webrat</dt>
              <dd>bryan</dd>
              <dt>cucumber</dt>
              <dd>aslak</dd>
            </dl>
          HTML

          _tableish(html, 'dl#tools dt', lambda { |dt| [dt, dt.next.next] }).should == [
            %w{ webrat bryan },
            %w{ cucumber aslak }
          ]
        end

        it "should convert a ul" do
          html = <<-HTML
            <ul id="phony">
              <li>nope</li>
            </ul>

            <ul id="yes">
              <li>webrat</li>
              <li>bryan</li>
              <li>cucumber</li>
              <li>aslak</li>
            </ul>
          HTML

          _tableish(html, 'ul#yes li', lambda { |li| [li] }).should == [
            %w{ webrat },
            %w{ bryan },
            %w{ cucumber },
            %w{ aslak },
          ]
        end

        it "should handle selector lambdas" do
          html = <<-HTML
            <form method="post" action="/invoices/10/approve" class="button-to">
              <div>
                <input id="approve_invoice_10" type="submit" value="Approve" />
                <input name="authenticity_token" type="hidden" value="WxKGVy3Y5zcvFEiFe66D/odoc3CicfMdAup4vzQfiZ0=" />
                <span>Hello&nbsp;World<span>
              </div>
            </form>
            <form method="post" action="/invoices/10/delegate" class="button-to">
              <div>
                <input id="delegate_invoice_10" type="submit" value="Delegate" />
                <input name="authenticity_token" type="hidden" value="WxKGVy3Y5zcvFEiFe66D/odoc3CicfMdAup4vzQfiZ0=" />
                <span>Hi There<span>
              </div>
            </form>
          HTML

          selectors = lambda do |form|
            [
              form.css('div input:nth-child(1)').first.attributes['value'],
              form.css('span').first.text.gsub(/\302\240/, ' ')
            ]
          end

          _tableish(html, 'form', selectors).should == [
            ['Approve', "Hello World"],
            ['Delegate', 'Hi There']
          ]
        end
      end
    end
  end
end
