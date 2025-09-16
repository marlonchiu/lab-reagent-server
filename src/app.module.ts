import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserModule } from './user/user.module';
import { LaboratoryModule } from './laboratory/laboratory.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true, // 使 ConfigModule 在全局可用
    }),
    // MongooseModule.forRoot('mongodb://127.0.0.1:27017/lab-reagent'),
    MongooseModule.forRoot(
      `mongodb://${process.env.MONGO_HOST}:${process.env.MONGO_PROT}/${process.env.MONGO_DATABASE}`,
    ),
    UserModule,
    LaboratoryModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
