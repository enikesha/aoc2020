var input=await(await fetch(document.location.href.replace(/#.*$/, "") + "/input")).text()

console.log(Object.values(input.split('\n').slice(0,-1).reduce(([or,and,mem], cmd) => cmd.startsWith('mask = ') ? [...(cmd.substring(7).split('').reduce(([o,a],b)=>[o*2n+(b=="1"?1n:0n),a*2n+(b=="0"?0n:1n)],[0n,0n])), mem]:[or,and, (m=>{var [a,v]=cmd.split(' = '); m[a] = BigInt(v)&and|or;return m})(mem)], [0n,0n,{}])[2]).reduce((a,x)=>a+x,0n))
