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
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { LaboratoryService } from './laboratory.service';
import { LaboratoryDto } from './dto/laboratory.dto';
import { Public } from 'src/auth/decorators/public.decorator';

// @Controller('laboratory')
@Controller({ path: 'laboratory', version: '1.0' })
@ApiTags('实验室管理 Laboratory')
export class LaboratoryController {
  constructor(private readonly laboratoryService: LaboratoryService) {}

  // 分页查询
  @Public()
  @ApiOperation({ summary: '分页查询' })
  @ApiQuery({ name: 'keyword', type: String, required: false, description: '搜索关键词' })
  @ApiQuery({ name: 'pageNum', type: Number, required: false, description: '页码' })
  @ApiQuery({ name: 'pageSize', type: Number, required: false, description: '每页数量' })
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
  @Public()
  @ApiOperation({ summary: '列表查询' })
  @ApiQuery({ name: 'keyword', type: String, required: false, description: '搜索关键词' })
  @Get('/list')
  async list(@Query('keyword') keyword: string) {
    const list = await this.laboratoryService.findList({ keyword });
    return list;
  }

  // 创建
  @ApiOperation({ summary: '创建' })
  @Post('/save')
  async save(@Request() req, @Body() dataDto: LaboratoryDto) {
    try {
      const { id: userId } = req.user;
      return await this.laboratoryService.create(userId, dataDto);
    } catch (error) {
      throw new HttpException(error, HttpStatus.BAD_REQUEST);
    }
  }

  // 更新
  @ApiOperation({ summary: '更新' })
  @ApiBearerAuth() // 表示当前接口请求头需要添加authorization
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
  @ApiOperation({ summary: '查询单条信息' })
  @Get('/getById/:id')
  getById(@Param('id') id: string) {
    return this.laboratoryService.findOne(id);
  }

  // 删除
  @ApiOperation({ summary: '删除' })
  @Delete('/deleteById/:id')
  deleteById(@Param('id') id: string) {
    return this.laboratoryService.deleteOne(id);
  }
}
