
const App = {
    data() {
        return {
            show: false,
            shownotif: false,
            showshop: false,
            totalCost: 0,
            resource:[{"id": 1, "title":"Продвинутый ремкомплект", "name":"advancedlockpick", "img":"./img/advancedlockpick.png", "amount": 2},
                      {"id": 2, "title":"Канистра", "name":"advancedlockpick", "img":"./img/advancedlockpick.png", "amount": 1}
            ],
            shopItems:[
                {"id": 1, "label":"Свинка", "name":"a_c_pig", "price":100, "image": "./img/icons/a_c_pig.ico", "amount":0},
                {"id": 2, "label":"Свинка", "name":"a_c_cow", "price":200, "image": "./img/icons/a_c_cow.ico",  "amount":0}, 
                {"id": 3, "label":"Свинка", "name":"a_c_hen", "price":50, "image": "./img/icons/a_c_hen.ico",  "amount":0}, 
                {"id": 4, "label":"Свинка", "name":"animalfood", "price":10, "image": "./img/icons/animalFood.png",  "amount":0}, 
            ],
            basket:[
                /*{"id": 1, "name":"a_c_pig", "price":100, "amount":1, "image": "./img/icons/a_c_pig.ico"},
                {"id": 2, "name":"a_c_cow", "price":300, "amount":3, "image": "./img/icons/a_c_cow.ico"},
                {"id": 3, "name":"a_c_cow", "price":300, "amount":3, "image": "./img/icons/a_c_cow.ico"}*/
            ],
          
            
        }
    },    
    

   
    components:{},
    methods: {
        onClose() {
           
            this.show = false;
            $.post('https://farm/close');
            Clear()

        },
        addToBasket(item) {
            console.log(item.price, Number(item.amount))
            if(Number(item.amount)>0) {
                let bool = true
                for (let i = 0; i < this.basket.length; i += 1) {
                    let basketItem = this.basket[i]
                    console.log(basketItem.name, item.name)
                    if (basketItem.name === item.name) {
                            bool = false
                            return
                    }
                }
                if (bool) {
                    let temparyItem = {
                        id: this.basket.length+1,
                        name: item.name,
                        price: item.price,
                        amount: item.amount,
                        image: item.image
                    }
                    this.totalCost = this.totalCost + (item.price*item.amount)
                    this.basket.push(temparyItem);
                }else {
                
                }
            } else {
              
            }
            
        },
        Clear() {
            this.basket = []
            this.totalCost = 0
            for (let i = 0; i < this.shopItems.length; i += 1) {
                this.shopItems[i].amount = 0
            }
        },
        Buy() {
            $.post('https://farm/buy',JSON.stringify({basket:this.basket, totalCost:this.totalCost}));
            this.Clear();
        },

      
},

    mounted() {
        this.listener = window.addEventListener("message", (event) => {
            //console.log('test window.addEventListener', event.data.action)
            if(event.data.action === 'openNotify') {
                this.show = true;
                this.shownotif = true;
                this.showshop = false;
                this.resource = event.data.need
            }
            else if(event.data.action === 'openShop') {
                this.show = true;
                this.shownotif = false;
                this.showshop = true;
                console.log(JSON.stringify(this.shopItems))
            } else if(event.data.action === 'close') {
                this.onClose();
            }
            
        });
        window.document.onkeydown = event => event && event.code === 'Escape' ? this.onClose() : null
      },
   
    }



let app = Vue.createApp(App)
app.mount('#app')