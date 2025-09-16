import { Module } from '@nestjs/common';
import { LaboratoryController } from './laboratory.controller';
import { LaboratoryService } from './laboratory.service';
import { MongooseModule } from '@nestjs/mongoose';
import { Laboratory, LaboratorySchema } from './schemas/laboratory.schema';

@Module({
  imports: [MongooseModule.forFeature([{ name: Laboratory.name, schema: LaboratorySchema }])],
  controllers: [LaboratoryController],
  providers: [LaboratoryService],
})
export class LaboratoryModule {}
