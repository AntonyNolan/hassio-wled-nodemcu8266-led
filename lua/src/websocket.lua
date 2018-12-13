--SAFETRIM

do
  local websocket = {}
  _G.websocket = websocket
  local band = bit.band
  local bor = bit.bor
  local rshift = bit.rshift
  local lshift = bit.lshift
  local char = string.char
  local byte = string.byte
  local sub = string.sub
  local applyMask = crypto.mask
  local toBase64 = crypto.toBase64
  local hash = crypto.hash

  -- local function dump(o)
  --  if type(o) == 'table' then
  --    local s = '{ '
  --    for k, v in pairs(o) do
  --      if type(k) ~= 'number' then k = '"'..k..'"' end
  --      s = s .. '['..k..'] = ' .. dump(v) .. ','
  --    end
  --    return s .. '} '
  --  else
  --    return tostring(o)
  --  end
  -- end

  local function decode(chunk)
    if #chunk < 2 then return end
    local second = byte(chunk, 2)
    local len = band(second, 0x7f)
    local offset
    if len == 126 then
      if #chunk < 4 then return end
      len = bor(
        lshift(byte(chunk, 3), 8),
      byte(chunk, 4))
      offset = 4
    elseif len == 127 then
      if #chunk < 10 then return end
      len = bor(
        -- Ignore lengths longer than 32bit
        lshift(byte(chunk, 7), 24),
        lshift(byte(chunk, 8), 16),
        lshift(byte(chunk, 9), 8),
      byte(chunk, 10))
      offset = 10
    else
      offset = 2
    end
    local mask = band(second, 0x80) > 0
    if mask then
      offset = offset + 4
    end
    if #chunk < offset + len then return end

    local first = byte(chunk, 1)
    local payload = sub(chunk, offset + 1, offset + len)
    assert(#payload == len, "Length mismatch")
    if mask then
      payload = applyMask(payload, sub(chunk, offset - 3, offset))
    end
    local extra = sub(chunk, offset + len + 1)
    local opcode = band(first, 0xf)
    return extra, payload, opcode
  end

  local function encode(payload, opcode)
    opcode = opcode or 2
    assert(type(opcode) == "number", "opcode must be number")
    assert(type(payload) == "string", "payload must be string")
    local len = #payload
    local head = char(
      bor(0x80, opcode),
      bor(len < 126 and len or len < 0x10000 and 126 or 127)
    )
    if len >= 0x10000 then
      head = head .. char(
        0, 0, 0, 0, -- 32 bit length is plenty, assume zero for rest
        band(rshift(len, 24), 0xff),
        band(rshift(len, 16), 0xff),
        band(rshift(len, 8), 0xff),
        band(len, 0xff)
      )
    elseif len >= 126 then
      head = head .. char(band(rshift(len, 8), 0xff), band(len, 0xff))
    end
    return head .. payload
  end

  local guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
  local function acceptKey(key)
    return toBase64(hash("sha1", key .. guid))
  end

  local clients = {} -- Table of websocket client connections

  -- Broadcast message to all websocket clients

  function websocket.send(message)
    print("Heap Available: 1 " .. node.heap())
    for i, client in pairs(clients) do
      print("Heap Available: 2 " .. node.heap())
      print("Sending to client", i)
      client.send(message)
      print("Heap Available: 3 " .. node.heap())
    end
  end

  function websocket.createServer(port, callback)
    -- This is executed only once
    local connections = 0
    net.createServer(net.TCP):listen(port, function(conn)
      -- This is executed with every websocket client connection
      print("Client", conn:getpeer())
      local buffer = false
      local socket = {}
      local queue = {}
      local waiting = false
      connections = connections + 1
      local connection = connections

      local function onSend()
        if queue[1] then
          local data = table.remove(queue, 1)
          return conn:send(data, onSend)
        end
        waiting = false
      end

      function socket.send(...) -- Client function
        local data = encode(...)
        if not waiting then
          waiting = true
          conn:send(data, onSend)
        else
          queue[connection] = data
        end
      end

      conn:on("disconnection", function(_, message)
        print("Socket disconnected", connection)
        clients[connection] = nil
        conn = nil
        socket = nil
      end)

      clients[connection] = socket

      conn:on("receive", function(_, chunk)
        if buffer then
        buffer = buffer .. chunk
        while true do
          local extra, payload, opcode = decode(buffer)
          if not extra then return end
          buffer = extra

          if opcode == 9 then  -- WebSocket ping message
            tmr.softwd(600)
            socket.send(" ",0xA)   -- Pong message
          else
            socket.onmessage(payload, opcode) -- Pass message to calling application
          end
        end
      end
      local _, e, method = string.find(chunk, "([A-Z]+) /[^\r]* HTTP/%d%.%d\r\n")
      local key, name, value
      while true do
        _, e, name, value = string.find(chunk, "([^ ]+): *([^\r]+)\r\n", e + 1)
        if not e then break end
        if string.lower(name) == "sec-websocket-key" then
          key = value
        end
      end

      if method == "GET" and key then
        conn:send(
          "HTTP/1.1 101 Switching Protocols\r\n" ..
          "Upgrade: websocket\r\nConnection: Upgrade\r\n" ..
          "Sec-WebSocket-Accept: " .. acceptKey(key) .. "\r\n\r\n",
        function () callback(socket) end) -- Passback to caller
        buffer = ""
      else
        conn:send(
          "HTTP/1.1 404 Not Found\r\nConnection: Close\r\n\r\n",
        conn.close)
      end
    end) -- End of receive event

  end) -- End of createServer Listen
end

end
