import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types, HydratedDocument } from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

export type LaboratoryDocument = HydratedDocument<Laboratory>;

@Schema({
  timestamps: true, // 记录时间戳 crateAt & updateAt
})
export class Laboratory {
  // // 使用MongoDB ObjectId作为字符串ID
  // @Prop({
  //   required: true,
  //   unique: true,
  //   default: () => new Types.ObjectId().toString(),
  // })
  // id: string;

  @Prop({
    required: true,
    unique: true,
    default: () => uuidv4(), // 自动生成UUID
  })
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

  @Prop()
  created_by: string;
}

export const LaboratorySchema = SchemaFactory.createForClass(Laboratory);
