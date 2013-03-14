require 'net/http'
require "uri"
require 'json'

class BattleShip
  attr_reader :x, :y, :uri
  def initialize(pos)
    @uri = URI.parse("http://192.168.16.176:9393/fire")
    @x,@y = pos.split("")
  end

  def fire
    http = Net::HTTP.new(uri.host, uri.port)
    payload = { 'x' => x, "y" => y, "id" => "70350984599760" }.to_json
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.body = payload
    response = http.request(request)
    r = JSON.parse(response.body)
    [r["x"], r["y"], r["status"]]
  end
end

Shoes.app :width => 1040, :height => 520 do
  @your_board = {}
  @opponent_board = {}
  flow :width => 450, :height => 20 do
    @x = para "X:"
    @y = para "Y:"
    @status = para "status"
  end

  def board(rects)
    flow :width => 500, :height => 22 do
      flow :width => 43, :height => 22 do
      end
      10.times do |i|
        stack :width => 43, :height => 43 do
          para "#{i}"
        end
      end
    end

    flow :width => 472, :height => 500 do
      flow :width => 18, :height => 450 do
        flow :width => 18, :height => 15 do
        end
        10.times do |i|
          stack :width => 18, :height => 43, :margin => 2 do
            para "#{i}"
          end
        end
      end
      flow :width => 450, :height => 450, :margin => 10 do
        background rgb(67,67,67)
        10.times do |y|
          10.times do |x|
            pos = [x,y].join("")
            rects[pos] = stack :width => 43, :height => 43, :margin => 2 do
              image "sea_patt.png"
              click do |b,l,t|
                x,y,state = BattleShip.new(pos).fire
                background = state == "miss" ? "miss.png" : "ship.png"
                rects[pos].background background
                opponent_pos = [x,y].join("")
                @opponent_board[opponent_pos].background "miss.png"
                @x.replace("X: #{x}")
                @y.replace("Y: #{y}")
                @status.replace(state)
              end
            end
          end
        end
      end
    end
  end
  flow :width => 1000, :height => 1000 do
    stack :width => 500, :height => 500 do
      board(@your_board)
    end
    stack :width => 500, :height => 500 do
      board(@opponent_board)
    end
  end
end