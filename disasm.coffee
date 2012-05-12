assert = require 'assert'
fs = require 'fs'

log = (msg) -> console.log msg
fail = (msg) -> console.error msg; throw msg

padWithZeros = (length, string) ->
	while string.length < length
		string = '0' + string
	string

hex = (word) ->
	"0x#{padWithZeros 4, word.toString 16}"

hex2 = (word) ->
	"0x#{padWithZeros 2, word.toString 16}"


opnames = [
	'<n/a 0x00>'
	'set'
	'add'
	'sub'

	'mul'
	'mli'
	'div'
	'dvi'

	'mod'
	'mdi'
	'and'
	'bor'
	
	'xor'
	'shr'
	'asr'
	'shl'

	'ifb'
	'ifc'
	'ife'
	'ifn'

	'ifg'
	'ifa'
	'ifl'
	'ifu'

	'<n/a 0x18>'
	'<n/a 0x19>'
	'adx'
	'sbx'

	'<n/a 0x1c>'
	'<n/a 0x1d>'
	'sti'
	'std'
]

opnamesExt = [
	'reserved'
	'jsr'
	'<n/a 0x02>'
	'<n/a 0x03>'

	'<n/a 0x04>'
	'<n/a 0x05>'
	'<n/a 0x06>'
	'<n/a 0x07>'

	'int'
	'iag'
	'ias'
	'rfi'

	'iaq'
	'<n/a 0x0d>'
	'<n/a 0x0e>'
	'<n/a 0x0f>'

	'hwn'
	'hwq'
	'hwi'
]

regnames = [
	'a', 'b', 'c',
	'x', 'y', 'z',
	'i', 'j'
]

valuenames = new Array(0x1d)
valuenames[0x18..0x1d] = [
	'[--sp] or [sp++]'
	'[sp]'
	'[sp + next]' # won't be displayed
	'sp'
	'pc'
	'ex'
]

# Usage:
#
# d = new Disassembler()
# d.setCode "1234 5678 <...>"
# d.disasm()
class Disassembler
	# img is a buffer containing binary code in little endian
	setImg: (buffer) ->
		assert buffer.length % 2 == 0, "odd buffer length #{buffer.length}"
		@words = []
		if buffer.length
			for i in [0..buffer.length / 2 - 1]
				@words.push buffer.readUInt16BE 2*i
		
	# code is a sequence of 16-bit hex words separated by whitespace.
	setCode: (code) ->
		@words = code.split(/\s/).filter((s) -> s != '').map((s) -> parseInt s, 16)

	disasm: ->
		assert @words, "@words undefined"

		pos = 0
		next = => @words[pos++]

		printval = (value) ->
			if value in [0x00..0x07]
				regnames[value]
			else if value in [0x08..0x0f]
				'[' + regnames[value & 0x07] + ']'
			else if value in [0x10..0x17]
				"[#{hex next()} + " + regnames[value & 0x07] + ']'
			else if value == 0x1a
				"[sp + #{hex next()}"
			else if value in [0x18..0x1d]
				valuenames[value]
			else if value == 0x1e
				"[#{hex next()}]"
			else if value == 0x1f
				"#{hex next()}"
			else if value in [0x20..0x3f]
				hex2 (value & 0x1f) - 1
			else
				"<value #{hex value}>"

		decode = ->
			while word = next()
				take = (bits) ->
					mask = (1 << bits) - 1
					result = word & mask
					word >>= bits
					result

				isSpecial = (word & (1 << 5) - 1) == 0

				if isSpecial
					zeros = take 5
					assert zeros == 0
					op = take 5
					a = take 6
					b = undefined
					opname = opnamesExt[op] || "<special #{hex2 op}>"
				else
					op = take 5
					b = take 5
					a = take 6
					opname = opnames[op] || "<op #{hex2 op}>"

				aname = printval a
				bname = printval b if b?

				comment = ""
#				comment = "\t\t; b is #{b}, a is #{a}"
				if b?
					log "  #{opname} #{bname}, #{aname}#{comment}" 
				else
					log "  #{opname} #{aname}#{comment}"

		decode()

sampleCode = """
	7c01 0030
	7de1 1000 0020
	7803 1000
	c00d 
	7dc1 001a

	a861
	7c01 2000
	2161 2000
	8463
	806d
	7dc1 000d

	9031
	7c10 0018 
	7dc1 001a

	9037
	61c1

	7dc1 001a
"""

d = new Disassembler()
#d.setCode sampleCode
#d.disasm()

filename = 'samples/colortest.img'
fs.readFile filename, (err, result) ->
	if err
		fail "error reading #{filename}"
	d.setImg result
	d.disasm()

