log = (msg) -> console.log msg

padWithZeros = (length, string) ->
	while string.length < length
		string = '0' + string
	string

hex = (word) ->
	"0x#{padWithZeros 4, word.toString 16}"

hex2 = (word) ->
	"0x#{padWithZeros 2, word.toString 16}"


opnames = [
	'ext'
	'set'
	'add'
	'sub'

	'mul'
	'div'
	'mod'
	'shl'

	'shr'
	'and'
	'bor'
	'xor'

	'ife'
	'ifn'
	'ifg'
	'ifb'
]

opnamesExt = [
	'reserved'
	'jsr'
]

regnames = [
	'a', 'b', 'c',
	'x', 'y', 'z',
	'i', 'j'
]

valuenames = new Array(0x1d)
valuenames[0x18..0x1d] = [
	'[sp++]'
	'[sp]'
	'[--sp]'
	'sp'
	'pc'
	'o'
]

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

words = sampleCode.split(/\s/).filter((s) -> s != '').map((s) -> parseInt s, 16)

pos = 0
next = -> words[pos++]

printval = (value) ->
	if value in [0x00..0x07]
		regnames[value]
	else if value in [0x08..0x0f]
		'[' + regnames[value & 0x07] + ']'
	else if value in [0x10..0x17]
		"[#{hex next()} + " + regnames[value & 0x07] + ']'
	else if value in [0x18..0x1d]
		valuenames[value]
	else if value == 0x1e
		"[#{hex next()}]"
	else if value == 0x1f
		"#{hex next()}"
	else if value in [0x20..0x3f]
		hex2 value & 0x1f
	else
		"unknown value #{hex value}"
#	value
#	if value 

decode = ->
	while word = next()
		take = (bits) ->
			mask = (1 << bits) - 1
			result = word & mask
			word >>= bits
#			log "mask #{hex mask}, result #{hex result}, remnants of word #{hex word}"
			result

		op = take 4
		a = take 6
		b = take 6

		opname = opnames[op]
		if opname == 'ext'
			op = a
			a = b
			b = undefined
			opname = opnamesExt[op]

		aname = printval a
		bname = printval b if b

#		log "  #{hex op}, #{hex a}, #{hex b}"
		if b
			log "  #{opname} #{aname}, #{bname}"
		else
			log "  #{opname} #{aname}"

decode()