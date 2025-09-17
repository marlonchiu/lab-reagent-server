import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Laboratory } from './schemas/laboratory.schema';
import { LaboratoryDto } from './dto/laboratory.dto';

@Injectable()
export class LaboratoryService {
  constructor(
    // 依赖注入
    @InjectModel(Laboratory.name) private readonly laboratoryModel: Model<Laboratory>,
  ) {}

  async findPage({ keyword = '', pageNum = 1, pageSize = 10 }) {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.name = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.laboratoryModel
      .find(whereOpt)
      .sort({ _id: 1 })
      .skip((pageNum - 1) * pageSize) // 跳过
      .limit(pageSize) // 限制
      .exec();
  }

  async countAll({ keyword = '' }) {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.name = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.laboratoryModel.countDocuments(whereOpt);
  }

  async findList({ keyword = '' }) {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.name = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.laboratoryModel.find(whereOpt).sort({ _id: 1 }).exec();
  }

  // 创建
  async create(dataDto: LaboratoryDto) {
    const createdLab = new this.laboratoryModel(dataDto);
    return await createdLab.save();
  }

  // 查询单个
  async findOne(id: string): Promise<any> {
    // 原来的方式（查找 _id）
    // return await this.laboratoryModel.findById(id);

    // 修改为查询自定义 id 字段
    return await this.laboratoryModel.findOne({ id: id });
  }

  // 通过 MongoDB _id 查找
  async findByObjectId(objectId: string): Promise<any> {
    return await this.laboratoryModel.findById(objectId);
  }

  // 更新
  async updateOne(id: string, updateData: LaboratoryDto): Promise<any> {
    return await this.laboratoryModel.updateOne({ id: id }, updateData);
  }
  // 删除单个
  async deleteOne(id: string): Promise<any> {
    return await this.laboratoryModel.findOneAndDelete({ id });
  }
}
