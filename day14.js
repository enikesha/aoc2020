var input=await(await fetch(document.location.href.replace(/#.*$/, "") + "/input")).text()

console.log(Object.values(input.split('\n').slice(0,-1).reduce(([or,and,mem], cmd) => cmd.startsWith('mask = ') ? [...(cmd.substring(7).split('').reduce(([o,a],b)=>[o*2n+(b=="1"?1n:0n),a*2n+(b=="0"?0n:1n)],[0n,0n])), mem]:[or,and, (m=>{var [a,v]=cmd.split(' = '); m[a] = BigInt(v)&and|or;return m})(mem)], [0n,0n,{}])[2]).reduce((a,x)=>a+x,0n))

function applyMask(mask, address) {
  return mask
    .split('')
    .map((bit, idx) => (bit == '0' ? (BigInt(address) & (1n << BigInt(35-idx)) ? '1' : '0') : bit))
    .join('')
}

function explode(addr, prefix) {
  let xPos = addr.indexOf('X')
  if (xPos == -1)
    return [prefix+addr];

  let bits = addr.substring(0, xPos)

  return [...explode(addr.substring(xPos+1), prefix+bits+'0'),
          ...explode(addr.substring(xPos+1), prefix+bits+'1')]
}

function process([mask, mem], cmd) {
  if (cmd.startsWith('mask = '))
    return [cmd.substring(7), mem]

  let [addr, val] = cmd.substring(4).split('] = ')
  let addrs = explode(applyMask(mask, addr), '');

  addrs.forEach(a => mem[a] = BigInt(val))

  return [mask, mem]
}

console.log(Object.values(input.split('\n').slice(0,-1).reduce(process, ['', {}])[1]).reduce((a,x)=>a+x,0n))
