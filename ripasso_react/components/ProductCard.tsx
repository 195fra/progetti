import React from 'react';
import { TouchableHighlight, Text, View, Image } from 'react-native';
import { Product } from '../utils/types';
import { cleanImage } from '../api/shopApi';
import { cardStyle } from '../utils/styles';

type Props = {
  product: Product;
  onPress: () => void;
};

export default function ProductCard({ product, onPress }: Props) {
  return (
    <TouchableHighlight
      style={cardStyle.card}
      onPress={onPress}
      underlayColor="#F3F4F6"
    >
      <>
        <Image
          source={{ uri: cleanImage(product.images[0]) }}
          style={cardStyle.image}
          resizeMode="cover"
        />
        <View style={{ flex: 1 }}>
          <Text style={cardStyle.category}>{product.category.name}</Text>
          <Text style={cardStyle.name} numberOfLines={2}>{product.title}</Text>
          <Text style={cardStyle.price}>€ {product.price.toFixed(2)}</Text>
        </View>
      </>
    </TouchableHighlight>
  );
}
