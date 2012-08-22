$(document).ready(function(){
	$('.buy_now_btn').on('click', function(evt){
		evt.preventDefault();
		var id = $(evt.target).attr('data_id');
		$.ajax({
			url:'/buy_now',
			type:'POST',
			data:{id:id},
			success:function(data){
				if(data.success){
					refresh_cart();
				}else{
					null
				}
			}
		});
		return false;
	});

	$('.add_to_cart_btn').on('click', function(evt){
		evt.preventDefault();
		var id = $(evt.target).attr('data_id');
		$.ajax({
			url:'/cart/add',
			type:'POST',
			data:{id:id},
			success:function(data){
				console.log("Added to cart");
				if(data.success){
					refresh_cart();
				}else{
					null
				}
			}
		});
		return false;
	});

	$('.delete_from_cart').live('click', function(evt){
		console.log("delete from cart activated");	
		evt.preventDefault();
    var id = $(evt.target).attr('data_id');
		$.ajax({
			url:'/cart/remove',
			data:{id:id},
			type:'DELETE',
			success:function(data){
				if(data.success){
					refresh_cart();
				}
			}
		});
		return false;
	});

	function refresh_cart(){
		$.ajax({
			url:"/cart",
			type:'GET',
			success:function(data){
				var total = 0;
				if(data.cart_items.length==0){
					$('#cart_items').text('You have no items in your cart, start adding them by clicking on "Add to cart" or to just buy one product "Buy now"');
					$('#cart_actions').hide();
					$('#cart_total').hide();
				}else{
					$('#cart_actions').show();
					cart_html = "";
					$.each(data.cart_items, function(i) {
						item = data.cart_items[i];
						console.log(item);
						cart_html= cart_html +'<div class="item_holder"><a href="\/appliances\/'+item.item_type+'\/'+item.appliance_id+'">' + item.model_name+'<\/a><span>'+item.brand+'  '+item.item_type+'</span><span>'+item.numbers+'</span><span>'+item.price+'</span><a class="delete_from_cart" href="#" data_id='+item.appliance_id+'>delete</a></div>';
						total += (parseInt(item.numbers)*parseInt(item.price));
					});
					$('#cart_items').html(cart_html);
					$('#cart_total').html('<span><h3>Total</h3><em>'+total +'</em></span>');
					console.log($('.delete_from_cart'));
					$('#cart_actions').show();
					$('#cart_total').show();
				}
		}
	});}

	// Important !! to refresh cart on load
		refresh_cart();
});
