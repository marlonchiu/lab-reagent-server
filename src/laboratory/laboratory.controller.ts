import {
  Controller,
  Get,
  Query,
  Post,
  Body,
  Param,
  Delete,
  Put,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { LaboratoryService } from './laboratory.service';
import { LaboratoryDto } from './dto/laboratory.dto';

@Controller('laboratory')
export class LaboratoryController {
  constructor(private readonly laboratoryService: LaboratoryService) {}

  // 分页查询
  @Get('/page')
  async page(
    @Query('keyword') keyword: string,
    @Query('pageNum') pageNum: number,
    @Query('pageSize') pageSize: number,
  ) {
    const list = await this.laboratoryService.findPage({ keyword, pageNum, pageSize });
    const count = await this.laboratoryService.countAll({ keyword });
    return {
      records: list,
      total: count,
    };
  }

  // 列表查询
  @Get('/list')
  async list(@Query('keyword') keyword: string) {
    const list = await this.laboratoryService.findList({ keyword });
    return list;
  }

  // 创建
  @Post('/save')
  async save(@Body() dataDto: LaboratoryDto) {
    try {
      return await this.laboratoryService.create(dataDto);
    } catch (error) {
      throw new HttpException(error, HttpStatus.BAD_REQUEST);
    }
  }

  // 更新
  @Put('/update/:id')
  async update(@Param('id') id: string, @Body() dataDto: LaboratoryDto) {
    const data = await this.laboratoryService.updateOne(id, dataDto);
    // 修改成功 返回当前数据的id
    if (data.modifiedCount === 1) {
      // 返回最新数据
      // return id;
      return this.laboratoryService.findOne(id);
    } else {
      throw new HttpException('更新失败', HttpStatus.BAD_REQUEST);
    }
  }

  // 查询单条信息一条
  @Get('/getById/:id')
  getById(@Param('id') id: string) {
    return this.laboratoryService.findOne(id);
  }

  // 删除
  @Delete('/deleteById/:id')
  deleteById(@Param('id') id: string) {
    return this.laboratoryService.deleteOne(id);
  }
}
