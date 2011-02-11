function to_comma(price){
	char_price = price;
	// 콤마찍기
	var reg = /(^[+-]?\d+)(\d{3})/;   // 정규식
	char_price += '';                // 숫자를 문자열로 변환

	while (reg.test(char_price))
	char_price = char_price.replace(reg, '$1' + ',' + '$2');
	
	return char_price;
}


$('.check_all').live("click", function(){
	if ( $('#all_checked').val() == "false" ){
		
		$('.chk_box').each(function(){
			$(this).attr("checked", true);
		})
		
		$('#all_checked').val("true");
	}else{
		$('.chk_box').each(function(){
			$(this).attr("checked", false);
		})
		
		$('#all_checked').val("false");
	}
})