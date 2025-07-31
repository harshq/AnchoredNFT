export interface Attribute {
  trait_type: string;
  value: string;
}

export interface Metadata {
  attributes: Attribute[];
  description: string;
  image: string;
  name: string;
}
