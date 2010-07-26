// 입력값의 한문자씩의 ascii 코드값을 가져와서, 0~127까지면 정상적인 값이며,
// 그외는 특수문자나 한글임을 판단하고 처리하는 함수
function input_check(string) {
 var txt = string;
 var cnt = 0;
 for(i=0; i<txt.length; i++) {
  if(txt.charCodeAt(i)>=0 && txt.charCodeAt(i)<=127) {
   // ascii
  } else {
   // not ascii
   cnt++;
  }
  if(cnt!=0) return false; 
 } 
}
