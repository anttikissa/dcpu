
log = (msg) -> console.log msg

hex = (word) ->
	"0x#{word.toString 16}"

log 'Hello world'

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

regnames = [
	
]

printval = (value) ->
	hex value
#	value
#	if value 
	
decode = (word) ->
	take = (bits) ->
		mask = (1 << bits) - 1
		result = word & mask
		word >>= bits
		log "mask #{hex mask}, result #{hex result}, remnants of word #{hex word}"
		result

	op = take 4
	a = take 6
	b = take 6

	opname = opnames[op]
	aname = printval a
	bname = printval b

	log "  #{opname} #{aname}, #{bname}"

decode 0x7c01

