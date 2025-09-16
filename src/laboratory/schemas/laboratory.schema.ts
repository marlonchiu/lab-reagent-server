import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type LaboratoryDocument = HydratedDocument<Laboratory>;

@Schema({
  timestamps: true, // 记录时间戳 crateAt & updateAt
})
export class Laboratory {
  @Prop({ required: true, unique: true })
  id: string;

  @Prop({ required: true, unique: true })
  name: string;

  @Prop()
  description: string;

  @Prop()
  location: string;

  @Prop()
  contact_person: string;

  @Prop()
  contact_phone: string;

  @Prop({ default: true })
  is_active: boolean;
}

export const LaboratorySchema = SchemaFactory.createForClass(Laboratory);
