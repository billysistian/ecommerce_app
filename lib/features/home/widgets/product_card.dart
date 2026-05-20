import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';



import '../../../models/product_model.dart';



class ProductCard extends StatelessWidget {

  final ProductModel product;



  const ProductCard({super.key, required this.product});



  @override

  Widget build(BuildContext context) {

    return Card(

      clipBehavior: Clip.antiAlias,



      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),



      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,



        children: [

          Expanded(

            child: CachedNetworkImage(

              imageUrl: 'http://10.0.2.2:8000/storage/${product.thumbnail}',



              width: double.infinity,

              fit: BoxFit.cover,



              errorWidget: (context, url, error) {

                return const Icon(Icons.image);

              },

            ),

          ),



          Padding(

            padding: const EdgeInsets.all(12),



            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,



              children: [

                Text(

                  product.name,



                  maxLines: 2,



                  overflow: TextOverflow.ellipsis,



                  style: const TextStyle(fontWeight: FontWeight.bold),

                ),



                const SizedBox(height: 8),



                const Text('View Product'),

              ],

            ),

          ),

        ],

      ),

    );

  }

}

