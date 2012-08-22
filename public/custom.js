$(document).ready(
		function(){
			$(''.delete_brand).on('click', function(evt){
				brand_id = $(evt.target).attr('_id');
				$.ajax({
					url:"/admin/destroy/brand/"+brand_id,
				  method:"DELETE",
					success: function(data){
						if(data.success){
							$(evt.target).parent.remove()
						}
					}
				})
			});
			console.log('Get out of here');

			$('a.filter_btn').on('click', function(evt){
				evt.preventDefault();
				console.log('Hello world');
				var category = $(evt.target).attr('data_cat');
				var property = $(evt.target).attr('data_prop');
				var value = $(evt.target).attr('data_value');
				$.ajax({
					url:'/showcase/'+ category,
					data:{
						category:category,property:property,value:value
					},
					type:'GET',
					success: function(data){
						$('.products_showcase').html(data);
					}
				});
				return false;
			});

			$('.delete_brand').on('click', function(evt){
				var id = $(evt.target).attr('data_id');
				$.ajax({
					url:'/admin/destroy/brand/'+id,
					type:'DELETE',
					success:function(data){
						if( data.success){
              $(evt.target).parent('li').fadeOut().remove();
						}else{
							$('.msg_box').html(data.msg)
						}
					}
				});
			});

			$('.delete_appliance').on('click', function(evt){
				evt.preventDefault();
				var url = $(evt.target).attr('href');
				$.ajax({
					url:url,
					type:'DELETE',
					success:function(data){
						if( data.success){
              $(evt.target).parent('div.small_appliance_box').fadeOut().remove();
						}else{
							$('.msg_box').html(data.msg)
					    console.log("Error in delete appliance");
						}
					}
				});
				return false;
			});
		}
		);
