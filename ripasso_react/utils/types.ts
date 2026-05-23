// ─── Tipi condivisi in tutta l'app ───────────────────────

export type Category = {
  id: number;
  name: string;
  image: string;
};

export type Product = {
  id: number;
  title: string;
  price: number;
  description: string;
  category: Category;
  images: string[];
};

export type CartItem = {
  product: Product;
  quantity: number;
};
