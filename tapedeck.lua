-- tape effects


engine.name="Tapedeck"

counter=0
tape_spin=0
font_level=15
message="drive=0.5"
pcur=1

groups={
  {"tape_wet","saturation","drive"},
  {"dist_wet","lowgain","highgain"},
  {"wowflu","wobble_amp","flutter_amp"},
}

function init()
  params:add_control("amp","amp",controlspec.new(0,1,'lin',0.01/1,1,'',0.1/1))
  params:set_action("amp",function(x)
    engine.amp(x)
    msg("amp="..(math.floor(x*10)/10))
  end)
  params:add_separator("tape")
  local ps={
    {"tape_wet","wet",0},
    {"tape_bias","bias",50},
    {"saturation","sat",50},
    {"drive","drive",50},
  }
  for _, p in ipairs(ps) do
    params:add_control(p[1],p[2],controlspec.new(0,100,'lin',1,p[3],"%",1/100))
    params:set_action(p[1],function(x)    
      engine[p[1]](x/100)
      msg(p[2].."="..math.floor(x).."%")
    end)
  end
  params:add_separator("distortion")
  local ps={
    {"dist_wet","wet",0},
    {"drivegain","drive",10},
    {"dist_bias","bias",0},
    {"lowgain","low",10},
    {"highgain","high",10},
  }
  for _, p in ipairs(ps) do
    params:add_control(p[1],p[2],controlspec.new(0,100,'lin',1,p[3],"%",1/100))
    params:set_action(p[1],function(x)    
      engine[p[1]](x/100)
      msg(p[2].."="..math.floor(x).."%")
    end)
  end
  params:add_control("shelvingfreq","shelving freq",controlspec.new(20,16000,'exp',10,600,'Hz',10/16000))
  params:set_action("shelvingfreq",function(x)
    engine.shelvingfreq(x)
  end)


  params:add_separator("wow / flutter")
  local ps={
    {"wowflu","wet",0},
    {"wobble_amp","wobble",5},
    {"flutter_amp","flutter",3},
  }
  for _, p in ipairs(ps) do
    params:add_control(p[1],p[2],controlspec.new(0,100,'lin',1,p[3],"%",1/100))
    params:set_action(p[1],function(x)    
      engine[p[1]](x/100)
      msg(p[2].."="..math.floor(x).."%")
    end)
  end
  params:add_control("wobble_rpm","wobble rpm",controlspec.new(1,66,'lin',1,33,'rpm',1/66))
  params:set_action("wobble_rpm",function(x)
    engine.wobble_rpm(x)
  end)
  params:add_control("flutter_fixedfreq","flutter freq",controlspec.new(0.1,10,'lin',0.1,6,'Hz',0.1/10))
  params:set_action("flutter_fixedfreq",function(x)
    engine.flutter_fixedfreq(x)
  end)
  params:add_control("flutter_variationfreq","flutter var freq",controlspec.new(0.1,10,'lin',0.1,2,'Hz',0.1/10))
  params:set_action("flutter_variationfreq",function(x)
    engine.flutter_variationfreq(x)
  end)


  params:bang()

  msg("MIX"..math.random(1,12),30)

  clock.run(function()
      while true do 
          clock.sleep(1/10)
          redraw()
      end
  end)
end




function key(k,z)
  if k>1 and z==1 then
    pcur=util.clamp(pcur+(k*2-5),1,3)
    if pcur==1 then 
      msg("tape fx")
    elseif pcur==2 then
      msg("dist fx")
    elseif pcur==3 then
      msg("wow/flu")
    end
  end
end

function enc(k,d)
  local name=groups[pcur][k]
  params:delta(name,d)
end

function msg(s,l)
  message=s
  font_level=l or 15
end

function rect(x1,y1,x2,y2,l)
  screen.level(l or 15)
  screen.rect(x1,y1,x2-x1+1,y2-y1+1)
  screen.fill()
end

function erase(x,y)
  screen.level(0)
  screen.pixel(x,y)
  screen.fill()
end

function circle(x,y,r,l)
  screen.level(l)
  screen.circle(x,y,r)
  screen.fill()
end



function redraw()
    screen.clear()
    screen.aa(1)
    counter=counter+1
    tape_spin=tape_spin+(counter%math.random(1,4)==0 and 1 or 0)
    if tape_spin==5 then 
      tape_spin=0
    end
    local tape_color=15
    local band_color=9
    local bot_color=6
    local ring_color=12
    local magnet_color=2
    local magnet_inner=0
    local window_color=10
    local inner_tape_dark=0
    local inner_tape_light=4
    local very_bottom=13
    rect(21,3,109,59,tape_color)
    rect(21,3,22,4,0)
    rect(23,5,24,6,0)
    rect(21,58,22,59,0)
    rect(23,56,24,57,0)
    rect(106,5,107,6,0)
    rect(108,3,109,4,0)
    rect(106,56,107,57,0)
    rect(108,58,109,59,0)
    rect(25,9,105,23,0)
    rect(25,9,26,10,tape_color)
    rect(104,9,105,10,tape_color)
    rect(25,24,105,25,band_color)
    rect(25,26,105,46,bot_color)
    rect(36,26,94,40,ring_color)
    rect(36,26,37,27,bot_color)
    rect(36,39,37,40,bot_color)
    rect(93,26,94,27,bot_color)
    rect(93,39,94,40,bot_color)
    rect(38,28,47,38,magnet_color)
    rect(38,28,39,29,ring_color)
    rect(46,28,47,29,ring_color)
    rect(38,36,39,38,ring_color)
    rect(46,36,47,38,ring_color)
    rect(80,28,90,38,magnet_color)
    rect(80,28,82,29,ring_color)
    rect(89,28,90,29,ring_color)
    rect(80,36,82,38,ring_color)
    rect(89,36,90,38,ring_color)
    rect(38,34-tape_spin,39,35-tape_spin,magnet_inner)
    rect(40+tape_spin,28,41+tape_spin,29,magnet_inner)
    rect(46,30+tape_spin,47,31+tape_spin,magnet_inner)
    rect(44-tape_spin,36,45-tape_spin,38,magnet_inner)

    rect(80,34-tape_spin,82,35-tape_spin,magnet_inner)
    rect(83+tape_spin,28,84+tape_spin,29,magnet_inner)
    rect(89,30+tape_spin,90,31+tape_spin,magnet_inner)
    rect(87-tape_spin,36,88-tape_spin,38,magnet_inner)
    
    rect(53,28,75,33,window_color)
    rect(55,34,56,35,window_color)
    rect(59,34,60,35,window_color)
    rect(63,34,66,35,window_color)
    rect(68,34,69,35,window_color)
    rect(72,34,73,35,window_color)
    
    rect(61,28,69,33,inner_tape_dark)
    rect(70,28,71,33,inner_tape_light)
    rect(72,28,75,33,window_color-1)
    
    rect(36,49,92,57,very_bottom)
    rect(33,56,35,57,very_bottom)
    rect(93,56,94,57,very_bottom)
    rect(36,49,37,50,tape_color)
    rect(91,49,92,50,tape_color)
    
    
    rect(40,53,43,55,magnet_color)
    rect(51,53,52,55,magnet_color)
    rect(76,53,77,55,magnet_color)
    rect(85,53,87,55,magnet_color)
    rect(61,51,62,52,magnet_color)
    rect(66,51,67,52,magnet_color)
    
    if font_level>0 then 
      font_level=font_level-1
      screen.aa(0)
      screen.font_face(15)
      screen.font_size(11)
      screen.move(64,21)
      screen.level(font_level>15 and 15 or font_level)
      screen.text_center(message)
    end

    screen.update()
end
