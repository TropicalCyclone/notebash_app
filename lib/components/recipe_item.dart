import 'package:flutter/material.dart';
import 'package:notebash_app/models/recipe.dart';

class RecipeItem extends StatelessWidget {
  final void Function() onTap;
  final Recipe recipe;

  const RecipeItem({super.key, required this.onTap, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(recipe.color),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                "Ingredients",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(recipe.ingredients,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text(
                "Directions",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(recipe.directions,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
